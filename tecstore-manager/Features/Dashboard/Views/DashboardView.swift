import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Header gradient (card, no ignoresSafeArea)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bienvenido 👋")
                        .font(AppFonts.caption())
                        .foregroundColor(.white.opacity(0.8))
                    Text("TecStore Manager")
                        .font(AppFonts.largeTitle())
                        .foregroundColor(.white)
                    Text("Panel de Control")
                        .font(AppFonts.body())
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(AppColors.gradientPrimary)
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // MARK: Stat cards
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    GradientStatCard(
                        title: "Productos",
                        value: "\(viewModel.totalProductos)",
                        icon: "cube.box.fill",
                        gradient: AppColors.gradientPrimary
                    )
                    GradientStatCard(
                        title: "Clientes",
                        value: "\(viewModel.totalClientes)",
                        icon: "person.2.fill",
                        gradient: AppColors.gradientSuccess
                    )
                    GradientStatCard(
                        title: "Ventas",
                        value: "\(viewModel.totalVentas)",
                        icon: "cart.fill",
                        gradient: AppColors.gradientWarning
                    )
                    GradientStatCard(
                        title: "Ingresos",
                        value: "S/ \(String(format: "%.0f", viewModel.montoTotalVentas))",
                        icon: "banknote.fill",
                        gradient: AppColors.gradientPurple
                    )
                }
                .padding(.horizontal, 16)

                // MARK: Resumen de hoy
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Resumen de Hoy", icon: "sun.max.fill")
                    HStack(spacing: 0) {
                        TodayStat(
                            value: "\(viewModel.ventasHoy)",
                            label: "Ventas",
                            color: AppColors.primary
                        )
                        Divider().frame(height: 50)
                        TodayStat(
                            value: "S/ \(String(format: "%.2f", viewModel.montoHoy))",
                            label: "Recaudado",
                            color: AppColors.success
                        )
                    }
                    .background(AppColors.pageBackground)
                    .cornerRadius(10)
                }
                .cardStyle()
                .padding(.horizontal, 16)

                // MARK: Alertas stock bajo
                if !viewModel.productosConBajoStock.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(
                            title: "Stock Bajo",
                            icon: "exclamationmark.triangle.fill",
                            iconColor: AppColors.warning
                        )
                        ForEach(viewModel.productosConBajoStock) { product in
                            HStack {
                                Text(product.nombre)
                                    .font(AppFonts.body())
                                Spacer()
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(product.stock > 0 ? AppColors.warning : AppColors.danger)
                                        .frame(width: 7, height: 7)
                                    Text("\(product.stock) und.")
                                        .font(AppFonts.caption())
                                        .bold()
                                        .foregroundColor(product.stock > 0 ? AppColors.warning : AppColors.danger)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .cardStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.warning.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }

                // MARK: Ventas recientes
                if !viewModel.ventasRecientes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Ventas Recientes", icon: "clock.fill")
                        ForEach(viewModel.ventasRecientes) { sale in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Venta #\(sale.id.uuidString.prefix(8))")
                                        .font(AppFonts.headline())
                                    Text(sale.fecha, style: .date)
                                        .font(AppFonts.caption())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                                Text("S/ \(String(format: "%.2f", sale.total))")
                                    .font(AppFonts.headline())
                                    .foregroundColor(AppColors.primary)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 20)
        }
        .background(AppColors.pageBackground)
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadDashboard() }
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    let icon: String
    var iconColor: Color = AppColors.primary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// MARK: - TodayStat

struct TodayStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.title2())
                .bold()
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
