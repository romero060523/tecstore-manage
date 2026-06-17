import SwiftUI

struct ProductListView: View {
    @ObservedObject var viewModel: ProductListViewModel
    let onAdd: () -> Void
    let onEdit: (Producto) -> Void

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        CategoryChip(
                            title: cat,
                            isSelected: (viewModel.selectedCategory ?? "Todas") == cat
                        ) {
                            viewModel.selectedCategory = (cat == "Todas") ? nil : cat
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)

            Divider()

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.products.isEmpty {
                EmptyProductsView(searchText: viewModel.searchText)
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        ProductRow(product: product)
                            .contentShape(Rectangle())
                            .onTapGesture { onEdit(product) }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach {
                            viewModel.deleteProduct(id: viewModel.products[$0].id)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Productos")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear { viewModel.loadProducts() }
    }
}

// MARK: - SearchBar

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Buscar productos...", text: $text)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - CategoryChip

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ProductRow

private struct ProductRow: View {
    let product: Producto

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.nombre)
                    .font(.headline)
                    .lineLimit(1)
                Text(product.codigo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(product.categoria)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("S/ \(product.precio, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                HStack(spacing: 4) {
                    Circle()
                        .fill(product.stock > 0 ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text("Stock: \(product.stock)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if !product.estado {
                    Text("Inactivo")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EmptyProductsView

private struct EmptyProductsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(
                searchText.isEmpty
                    ? "No hay productos registrados"
                    : "Sin resultados para \"\(searchText)\""
            )
            .font(.headline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
