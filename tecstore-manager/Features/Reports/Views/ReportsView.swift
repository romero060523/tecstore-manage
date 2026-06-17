import SwiftUI

// MARK: - ReportsView

struct ReportsView: View {
    @ObservedObject var viewModel: ReportsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Rango de fechas
                VStack(spacing: 8) {
                    Text("Rango de Fechas").font(.headline)
                    HStack {
                        DatePicker(
                            "Desde",
                            selection: $viewModel.startDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        Text("—").foregroundColor(.secondary)
                        DatePicker(
                            "Hasta",
                            selection: $viewModel.endDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // MARK: Resumen general
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resumen General").font(.headline)
                    HStack {
                        ReportMetric(label: "Ventas",   value: "\(viewModel.resumen.ventas)")
                        ReportMetric(label: "Subtotal", value: "S/ \(viewModel.resumen.subtotal, default: "%.2f")")
                    }
                    HStack {
                        ReportMetric(label: "IGV",   value: "S/ \(viewModel.resumen.igv, default: "%.2f")")
                        ReportMetric(label: "Total", value: "S/ \(viewModel.resumen.total, default: "%.2f")")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // MARK: Top Productos
                if !viewModel.topProductos.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Productos").font(.headline)
                        ForEach(Array(viewModel.topProductos.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, alignment: .leading)
                                Text(item.nombre)
                                    .lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("S/ \(item.monto, specifier: "%.2f")")
                                        .font(.subheadline).bold()
                                    Text("\(item.cantidad) und.")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                            }
                            if index < viewModel.topProductos.count - 1 { Divider() }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // MARK: Top Clientes
                if !viewModel.topClientes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Clientes").font(.headline)
                        ForEach(Array(viewModel.topClientes.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, alignment: .leading)
                                Text(item.nombre)
                                    .lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("S/ \(item.monto, specifier: "%.2f")")
                                        .font(.subheadline).bold()
                                    Text("\(item.compras) compras")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                            }
                            if index < viewModel.topClientes.count - 1 { Divider() }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // MARK: Ventas por Categoría
                if !viewModel.ventasPorCategoria.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ventas por Categoría").font(.headline)
                        ForEach(Array(viewModel.ventasPorCategoria.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.categoria)
                                Spacer()
                                Text("\(item.cantidad) ventas")
                                    .font(.caption).foregroundColor(.secondary)
                                Text("S/ \(item.monto, specifier: "%.2f")")
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Reportes")
    }
}

// MARK: - ReportMetric

struct ReportMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption).foregroundColor(.secondary)
            Text(value)
                .font(.subheadline).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
