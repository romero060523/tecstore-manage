import SwiftUI

// MARK: - SaleListView

struct SaleListView: View {
    @ObservedObject var viewModel: SaleListViewModel
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SaleSummaryHeader(viewModel: viewModel)

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
                        .listRowBackground(AppColors.cardBackground)
                        .listRowSeparatorTint(AppColors.textTertiary.opacity(0.3))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.pageBackground)
            }
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Ventas")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onCreate) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear { viewModel.loadSales() }
    }
}

// MARK: - SaleSummaryHeader

private struct SaleSummaryHeader: View {
    @ObservedObject var viewModel: SaleListViewModel

    var body: some View {
        VStack(spacing: 12) {

            // Gradient summary card
            ZStack(alignment: .bottomLeading) {
                AppColors.gradientPrimary
                    .cornerRadius(20)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Ventas")
                            .font(AppFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(viewModel.totalVentas)")
                            .font(AppFonts.largeTitle())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Monto Total")
                            .font(AppFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                        Text("S/ \(String(format: "%.2f", viewModel.montoTotal))")
                            .font(AppFonts.title2())
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                .padding(20)
            }
            .frame(height: 110)
            .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)

            // Date filter toggle
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.showDateFilter.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                    Text(viewModel.startDate != nil ? "Filtro de fecha activo" : "Filtrar por fecha")
                        .font(AppFonts.caption())
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .rotationEffect(.degrees(viewModel.showDateFilter ? 180 : 0))
                }
                .foregroundColor(viewModel.startDate != nil ? AppColors.primary : AppColors.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.startDate != nil
                                ? AppColors.primary.opacity(0.3)
                                : AppColors.textTertiary.opacity(0.2),
                                lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if viewModel.showDateFilter {
                VStack(spacing: 10) {
                    DatePicker(
                        "Desde",
                        selection: Binding(
                            get: { viewModel.startDate ?? Date() },
                            set: { viewModel.startDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .tint(AppColors.primary)
                    DatePicker(
                        "Hasta",
                        selection: Binding(
                            get: { viewModel.endDate ?? Date() },
                            set: { viewModel.endDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .tint(AppColors.primary)
                    Button("Limpiar filtros") {
                        viewModel.startDate = nil
                        viewModel.endDate   = nil
                    }
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.danger)
                }
                .font(AppFonts.body())
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(AppColors.pageBackground)
    }
}

// MARK: - SaleRowView

struct SaleRowView: View {
    let sale: Venta
    let productName: String
    let clientName: String

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.gradientWarning)
                    .frame(width: 46, height: 46)
                Image(systemName: "cart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(productName)
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text(clientName)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label("\(sale.cantidad) und.", systemImage: "number")
                    Text("·")
                    Label("IGV S/ \(String(format: "%.2f", sale.igv))", systemImage: "percent")
                }
                .font(AppFonts.caption2())
                .foregroundColor(AppColors.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("S/ \(String(format: "%.2f", sale.total))")
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(AppColors.primary.opacity(0.08))
                    .cornerRadius(8)
                Text(sale.fecha, style: .date)
                    .font(AppFonts.caption2())
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - EmptySalesView

private struct EmptySalesView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.warning.opacity(0.07))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(AppColors.warning.opacity(0.10))
                    .frame(width: 90, height: 90)
                Image(systemName: "cart")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.warning.opacity(0.6))
            }
            Text("No hay ventas registradas")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textSecondary)
            Text("Toca + para registrar la primera venta")
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
