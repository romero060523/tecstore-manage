import SwiftUI

// MARK: - ReportsView

struct ReportsView: View {
    @ObservedObject var viewModel: ReportsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Rango de fechas
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Rango de Fechas", icon: "calendar")
                    HStack {
                        DatePicker(
                            "Desde",
                            selection: $viewModel.startDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .tint(AppColors.primary)
                        Text("—").foregroundColor(AppColors.textSecondary)
                        DatePicker(
                            "Hasta",
                            selection: $viewModel.endDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .tint(AppColors.primary)
                    }
                }
                .cardStyle()

                // MARK: Resumen general
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Resumen General", icon: "chart.bar.fill")
                    HStack(spacing: 12) {
                        ReportMetric(
                            label: "Ventas",
                            value: "\(viewModel.resumen.ventas)",
                            color: AppColors.primary
                        )
                        ReportMetric(
                            label: "Subtotal",
                            value: "S/ \(String(format: "%.2f", viewModel.resumen.subtotal))",
                            color: AppColors.success
                        )
                    }
                    HStack(spacing: 12) {
                        ReportMetric(
                            label: "IGV",
                            value: "S/ \(String(format: "%.2f", viewModel.resumen.igv))",
                            color: AppColors.warning
                        )
                        ReportMetric(
                            label: "Total",
                            value: "S/ \(String(format: "%.2f", viewModel.resumen.total))",
                            color: AppColors.purple
                        )
                    }
                }
                .cardStyle()

                // MARK: Top Productos
                if !viewModel.topProductos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Top Productos", icon: "cube.box.fill")
                        ForEach(Array(viewModel.topProductos.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.1))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(AppFonts.caption())
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.primary)
                                }
                                Text(item.nombre)
                                    .font(AppFonts.body())
                                    .lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("S/ \(String(format: "%.2f", item.monto))")
                                        .font(AppFonts.headline())
                                        .foregroundColor(AppColors.primary)
                                    Text("\(item.cantidad) und.")
                                        .font(AppFonts.caption2())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            if index < viewModel.topProductos.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .cardStyle()
                }

                // MARK: Top Clientes
                if !viewModel.topClientes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Top Clientes", icon: "person.2.fill")
                        ForEach(Array(viewModel.topClientes.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.success.opacity(0.1))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(AppFonts.caption())
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.success)
                                }
                                Text(item.nombre)
                                    .font(AppFonts.body())
                                    .lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("S/ \(String(format: "%.2f", item.monto))")
                                        .font(AppFonts.headline())
                                        .foregroundColor(AppColors.success)
                                    Text("\(item.compras) compras")
                                        .font(AppFonts.caption2())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            if index < viewModel.topClientes.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .cardStyle()
                }

                // MARK: Ventas por Categoría
                if !viewModel.ventasPorCategoria.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Ventas por Categoría", icon: "tag.fill")
                        ForEach(Array(viewModel.ventasPorCategoria.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.categoria)
                                    .font(AppFonts.body())
                                Spacer()
                                Text("\(item.cantidad) ventas")
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.trailing, 8)
                                Text("S/ \(String(format: "%.2f", item.monto))")
                                    .font(AppFonts.headline())
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    .cardStyle()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Reportes")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - ReportMetric

struct ReportMetric: View {
    let label: String
    let value: String
    var color: Color = AppColors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFonts.title2())
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.07))
        .cornerRadius(10)
    }
}
