import SwiftUI

// MARK: - SaleListView

struct SaleListView: View {
    @ObservedObject var viewModel: SaleListViewModel
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SaleSummaryCard(viewModel: viewModel)

            Divider()

            if viewModel.sales.isEmpty {
                EmptySalesView()
            } else {
                List {
                    ForEach(viewModel.sales) { sale in
                        SaleRowView(
                            sale:        sale,
                            productName: viewModel.getProductName(id: sale.productoId),
                            clientName:  viewModel.getClientName(id: sale.clienteId)
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Ventas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onCreate) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear { viewModel.loadSales() }
    }
}

// MARK: - SaleSummaryCard

private struct SaleSummaryCard: View {
    @ObservedObject var viewModel: SaleListViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Ventas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalVentas)")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Monto Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("S/ \(viewModel.montoTotal, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
            }

            Button {
                withAnimation { viewModel.showDateFilter.toggle() }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(viewModel.startDate != nil ? "Filtro activo" : "Filtrar por fecha")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(viewModel.showDateFilter ? 180 : 0))
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            if viewModel.showDateFilter {
                VStack(spacing: 8) {
                    DatePicker(
                        "Desde",
                        selection: Binding(
                            get: { viewModel.startDate ?? Date() },
                            set: { viewModel.startDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    DatePicker(
                        "Hasta",
                        selection: Binding(
                            get: { viewModel.endDate ?? Date() },
                            set: { viewModel.endDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    Button("Limpiar filtros") {
                        viewModel.startDate = nil
                        viewModel.endDate   = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - SaleRowView

struct SaleRowView: View {
    let sale: Venta
    let productName: String
    let clientName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(productName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(clientName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text("S/ \(sale.total, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            HStack {
                Label("\(sale.cantidad) und.", systemImage: "number")
                Spacer()
                Label("IGV: S/ \(sale.igv, specifier: "%.2f")", systemImage: "percent")
                Spacer()
                Text(sale.fecha, style: .date)
                    .font(.caption2)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EmptySalesView

private struct EmptySalesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No hay ventas registradas")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
