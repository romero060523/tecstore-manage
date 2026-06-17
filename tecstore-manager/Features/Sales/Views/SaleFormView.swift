import SwiftUI

struct SaleFormView: View {
    @ObservedObject var viewModel: SaleFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {
            // MARK: Cliente
            Section("Cliente") {
                TextField("Buscar cliente...", text: $viewModel.clientSearchText)
                    .autocorrectionDisabled()

                if let client = viewModel.selectedClient {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(client.nombres) \(client.apellidos)")
                            .bold()
                        Spacer()
                        Button("Cambiar") {
                            viewModel.selectedClient    = nil
                            viewModel.clientSearchText  = ""
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                } else {
                    ForEach(filteredClients) { client in
                        Button {
                            viewModel.selectedClient   = client
                            viewModel.clientSearchText = ""
                        } label: {
                            HStack {
                                Text("\(client.nombres) \(client.apellidos)")
                                Spacer()
                                Text("DNI: \(client.dni)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }

            // MARK: Producto
            Section("Producto") {
                TextField("Buscar producto...", text: $viewModel.productSearchText)
                    .autocorrectionDisabled()

                if let product = viewModel.selectedProduct {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.nombre)
                                .bold()
                            Text("S/ \(viewModel.precioUnitario, specifier: "%.2f") — Stock: \(viewModel.stockDisponible)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Cambiar") {
                            viewModel.selectedProduct   = nil
                            viewModel.productSearchText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                } else {
                    ForEach(filteredProducts) { product in
                        Button {
                            viewModel.selectedProduct   = product
                            viewModel.productSearchText = ""
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.nombre)
                                    Text("S/ \(product.precio, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("Stock: \(product.stock)")
                                    .font(.caption)
                                    .foregroundColor(product.stock > 5 ? .green : .orange)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }

            // MARK: Cantidad
            Section("Cantidad") {
                HStack {
                    Text("Unidades")
                    Spacer()
                    TextField("1", text: $viewModel.cantidad)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 80)
                }
                if viewModel.selectedProduct != nil {
                    Text("Disponible: \(viewModel.stockDisponible) unidades")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // MARK: Resumen
            Section("Resumen") {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text("S/ \(viewModel.subtotal, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("IGV (18%)")
                    Spacer()
                    Text("S/ \(viewModel.igv, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("TOTAL")
                        .bold()
                    Spacer()
                    Text("S/ \(viewModel.total, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }

            // MARK: Error
            if let error = viewModel.errorMessage {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                }
            }
        }
        .navigationTitle("Nueva Venta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Registrar") {
                    viewModel.save()
                }
                .fontWeight(.bold)
                .disabled(!viewModel.isFormValid)
            }
        }
        .onAppear {
            viewModel.onSave = onSave
        }
    }

    // MARK: - Computed Filters

    private var filteredClients: [Cliente] {
        guard !viewModel.clientSearchText.isEmpty else { return viewModel.clients }
        return viewModel.clients.filter {
            "\($0.nombres) \($0.apellidos)"
                .localizedCaseInsensitiveContains(viewModel.clientSearchText)
                || $0.dni.contains(viewModel.clientSearchText)
        }
    }

    private var filteredProducts: [Producto] {
        guard !viewModel.productSearchText.isEmpty else { return viewModel.products }
        return viewModel.products.filter {
            $0.nombre.localizedCaseInsensitiveContains(viewModel.productSearchText)
                || $0.codigo.localizedCaseInsensitiveContains(viewModel.productSearchText)
        }
    }
}
