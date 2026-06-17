import SwiftUI

struct ProductListView: View {
    @ObservedObject var viewModel: ProductListViewModel
    let onAdd: () -> Void
    let onEdit: (Producto) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                TextField("Buscar productos...", text: $viewModel.searchText)
                    .font(AppFonts.body())
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(AppColors.cardBackground)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // MARK: Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        let selected = (viewModel.selectedCategory ?? "Todas") == cat
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedCategory = (cat == "Todas") ? nil : cat
                            }
                        } label: {
                            Text(cat)
                                .font(AppFonts.caption())
                                .fontWeight(selected ? .semibold : .regular)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(selected ? AppColors.primary : AppColors.cardBackground)
                                .foregroundColor(selected ? .white : AppColors.textPrimary)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selected ? Color.clear : AppColors.primary.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: selected ? AppColors.primary.opacity(0.3) : .clear,
                                        radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)

            Divider()

            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.products.isEmpty {
                EmptyProductsView(searchText: viewModel.searchText)
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        ProductRow(product: product)
                            .contentShape(Rectangle())
                            .onTapGesture { onEdit(product) }
                            .listRowBackground(AppColors.cardBackground)
                            .listRowSeparatorTint(AppColors.textTertiary.opacity(0.3))
                    }
                    .onDelete { indexSet in
                        indexSet.forEach {
                            viewModel.deleteProduct(id: viewModel.products[$0].id)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.pageBackground)
            }
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Productos")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear { viewModel.loadProducts() }
    }
}

// MARK: - ProductRow

private struct ProductRow: View {
    let product: Producto

    var body: some View {
        HStack(spacing: 12) {

            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryColor(product.categoria).opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: categoryIcon(product.categoria))
                    .foregroundColor(categoryColor(product.categoria))
                    .font(.system(size: 20, weight: .medium))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.nombre)
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text(product.codigo)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSecondary)
                Text(product.categoria)
                    .font(AppFonts.caption2())
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(categoryColor(product.categoria).opacity(0.1))
                    .foregroundColor(categoryColor(product.categoria))
                    .cornerRadius(6)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("S/ \(String(format: "%.2f", product.precio))")
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.primary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(stockColor(product.stock))
                        .frame(width: 7, height: 7)
                    Text("\(product.stock) und.")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textSecondary)
                }
                if !product.estado {
                    Text("Inactivo")
                        .font(AppFonts.caption2())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(AppColors.danger.opacity(0.1))
                        .foregroundColor(AppColors.danger)
                        .cornerRadius(5)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func stockColor(_ stock: Int32) -> Color {
        if stock > 10 { return AppColors.success }
        if stock > 0  { return AppColors.warning }
        return AppColors.danger
    }
}

// MARK: - Category helpers

private func categoryIcon(_ cat: String) -> String {
    switch cat {
    case "Electrónica": return "cpu.fill"
    case "Ropa":        return "tshirt.fill"
    case "Alimentos":   return "cart.fill"
    case "Hogar":       return "house.fill"
    default:            return "tag.fill"
    }
}

private func categoryColor(_ cat: String) -> Color {
    switch cat {
    case "Electrónica": return AppColors.primary
    case "Ropa":        return AppColors.warning
    case "Alimentos":   return AppColors.success
    case "Hogar":       return AppColors.purple
    default:            return AppColors.textSecondary
    }
}

// MARK: - EmptyProductsView

private struct EmptyProductsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.05))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(AppColors.primary.opacity(0.08))
                    .frame(width: 90, height: 90)
                Image(systemName: "cube.box")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.primary.opacity(0.5))
            }
            Text(searchText.isEmpty
                 ? "No hay productos registrados"
                 : "Sin resultados para «\(searchText)»")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            if searchText.isEmpty {
                Text("Toca + para agregar el primer producto")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
