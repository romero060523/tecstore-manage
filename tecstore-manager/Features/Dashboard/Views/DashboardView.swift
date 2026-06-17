import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TecStore Manager")
                            .font(.title2).bold()
                        Text("Panel de Control")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "storefront.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)

                // MARK: Tarjetas de estadísticas
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    StatCard(title: "Productos", value: "\(viewModel.totalProductos)",
                             icon: "cube.box.fill",  color: .blue)
                    StatCard(title: "Clientes",  value: "\(viewModel.totalClientes)",
                             icon: "person.2.fill", color: .green)
                    StatCard(title: "Ventas",    value: "\(viewModel.totalVentas)",
                             icon: "cart.fill",     color: .orange)
                    StatCard(
                        title: "Ingresos",
                        value: "S/ \(viewModel.montoTotalVentas, default: "%.2f")",
                        icon: "banknote.fill",
                        color: .purple
                    )
                }
                .padding(.horizontal)

                // MARK: Resumen del día
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hoy").font(.headline)
                    HStack {
                        VStack(spacing: 4) {
                            Text("\(viewModel.ventasHoy)")
                                .font(.title).bold().foregroundColor(.blue)
                            Text("Ventas")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        Divider().frame(height: 40)

                        VStack(spacing: 4) {
                            Text("S/ \(viewModel.montoHoy, specifier: "%.2f")")
                                .font(.title3).bold().foregroundColor(.green)
                            Text("Recaudado")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // MARK: Alertas de stock bajo
                if !viewModel.productosConBajoStock.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Stock Bajo").font(.headline)
                            Spacer()
                            Text("\(viewModel.productosConBajoStock.count)")
                                .font(.caption)
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        ForEach(viewModel.productosConBajoStock) { product in
                            HStack {
                                Text(product.nombre).font(.subheadline)
                                Spacer()
                                Text("\(product.stock) und.")
                                    .font(.caption).bold()
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // MARK: Ventas recientes
                if !viewModel.ventasRecientes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ventas Recientes").font(.headline)
                        ForEach(viewModel.ventasRecientes) { sale in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Venta #\(sale.id.uuidString.prefix(8))")
                                        .font(.subheadline)
                                    Text(sale.fecha, style: .date)
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("S/ \(sale.total, specifier: "%.2f")")
                                    .bold().foregroundColor(.blue)
                            }
                            .padding(.vertical, 2)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Inicio")
        .onAppear { viewModel.loadDashboard() }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            Text(value)
                .font(.title3).bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
