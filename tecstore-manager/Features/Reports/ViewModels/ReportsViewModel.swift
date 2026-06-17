import Foundation
import Combine

final class ReportsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    @Published var ventasPorDia: [(fecha: String, monto: Double)] = []
    @Published var ventasPorCategoria: [(categoria: String, monto: Double, cantidad: Int)] = []
    @Published var topProductos: [(nombre: String, cantidad: Int, monto: Double)] = []
    @Published var topClientes: [(nombre: String, compras: Int, monto: Double)] = []
    @Published var resumen: (ventas: Int, subtotal: Double, igv: Double, total: Double) = (0, 0, 0, 0)

    // MARK: - Private

    private let saleService: SaleServiceProtocol
    private let productService: ProductServiceProtocol
    private let clientService: ClientServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        saleService: SaleServiceProtocol,
        productService: ProductServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        self.saleService    = saleService
        self.productService = productService
        self.clientService  = clientService

        $startDate.combineLatest($endDate)
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in self?.generateReport() }
            .store(in: &cancellables)

        generateReport()
    }

    // MARK: - Actions

    func generateReport() {
        let ventas = saleService.fetchAll(startDate: startDate, endDate: endDate)

        // Resumen general
        resumen = (
            ventas:   ventas.count,
            subtotal: ventas.reduce(0) { $0 + $1.subtotal },
            igv:      ventas.reduce(0) { $0 + $1.igv },
            total:    ventas.reduce(0) { $0 + $1.total }
        )

        // Diccionarios de lookup
        let allProducts = productService.fetchAll(searchText: nil, category: nil)
        let productDict = Dictionary(uniqueKeysWithValues: allProducts.map { ($0.id, $0) })
        let allClients  = clientService.fetchAll(searchText: nil)
        let clientDict  = Dictionary(uniqueKeysWithValues: allClients.map { ($0.id, $0) })

        // Top 5 productos
        var productSales: [UUID: (cantidad: Int, monto: Double)] = [:]
        for v in ventas {
            guard let pid = v.productoId else { continue }
            let prev = productSales[pid] ?? (0, 0)
            productSales[pid] = (prev.cantidad + Int(v.cantidad), prev.monto + v.total)
        }
        topProductos = productSales
            .map { pid, data in
                (nombre: productDict[pid]?.nombre ?? "Producto eliminado",
                 cantidad: data.cantidad,
                 monto: data.monto)
            }
            .sorted { $0.cantidad > $1.cantidad }
            .prefix(5)
            .map { $0 }

        // Ventas por categoría
        var catSales: [String: (monto: Double, cantidad: Int)] = [:]
        for v in ventas {
            guard let pid = v.productoId, let product = productDict[pid] else { continue }
            let cat  = product.categoria
            let prev = catSales[cat] ?? (0, 0)
            catSales[cat] = (prev.monto + v.total, prev.cantidad + 1)
        }
        ventasPorCategoria = catSales
            .map { cat, data in (categoria: cat, monto: data.monto, cantidad: data.cantidad) }
            .sorted { $0.monto > $1.monto }

        // Top 5 clientes
        var clientSales: [UUID: (compras: Int, monto: Double)] = [:]
        for v in ventas {
            guard let cid = v.clienteId else { continue }
            let prev = clientSales[cid] ?? (0, 0)
            clientSales[cid] = (prev.compras + 1, prev.monto + v.total)
        }
        topClientes = clientSales
            .map { cid, data -> (nombre: String, compras: Int, monto: Double) in
                let nombre: String
                if let c = clientDict[cid] { nombre = "\(c.nombres) \(c.apellidos)" }
                else { nombre = "Cliente eliminado" }
                return (nombre: nombre, compras: data.compras, monto: data.monto)
            }
            .sorted { $0.monto > $1.monto }
            .prefix(5)
            .map { $0 }

        // Ventas por día
        let df = DateFormatter()
        df.dateFormat = "dd/MM"
        var daySales: [String: Double] = [:]
        for v in ventas { daySales[df.string(from: v.fecha), default: 0] += v.total }
        ventasPorDia = daySales
            .map { (fecha: $0.key, monto: $0.value) }
            .sorted { $0.fecha < $1.fecha }
    }
}
