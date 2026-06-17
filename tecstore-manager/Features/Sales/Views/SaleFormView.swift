import SwiftUI

struct SaleFormView: View {
    @ObservedObject var viewModel: SaleFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {

            // MARK: Cliente
            Section {
                TextField("Buscar cliente...", text: $viewModel.clientSearchText)
                    .font(AppFonts.body())
                    .autocorrectionDisabled()

                if let client = viewModel.selectedClient {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 18))
                        Text("\(client.nombres) \(client.apellidos)")
                            .font(AppFonts.headline())
                        Spacer()
                        Button("Cambiar") {
                            viewModel.selectedClient   = nil
                            viewModel.clientSearchText = ""
                        }
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.primary)
                    }
                } else {
                    ForEach(filteredClients) { client in
                        Button {
                            viewModel.selectedClient   = client
                            viewModel.clientSearchText = ""
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(client.nombres) \(client.apellidos)")
                                        .font(AppFonts.body())
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("DNI: \(client.dni)")
                                        .font(AppFonts.caption())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                }
            } header: {
                Label("Cliente", systemImage: "person.fill")
                    .foregroundColor(AppColors.primary)
            }

            // MARK: Producto
            Section {
                TextField("Buscar producto...", text: $viewModel.productSearchText)
                    .font(AppFonts.body())
                    .autocorrectionDisabled()

                if let product = viewModel.selectedProduct {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 18))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.nombre)
                                .font(AppFonts.headline())
                            Text("S/ \(String(format: "%.2f", viewModel.precioUnitario))  ·  Stock: \(viewModel.stockDisponible)")
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Button("Cambiar") {
                            viewModel.selectedProduct   = nil
                            viewModel.productSearchText = ""
                        }
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.primary)
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
                                        .font(AppFonts.body())
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("S/ \(String(format: "%.2f", product.precio))")
                                        .font(AppFonts.caption())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(product.stock > 5 ? AppColors.success : AppColors.warning)
                                        .frame(width: 6, height: 6)
                                    Text("Stock: \(product.stock)")
                                        .font(AppFonts.caption())
                                        .foregroundColor(product.stock > 5 ? AppColors.success : AppColors.warning)
                                }
                            }
                        }
                    }
                }
            } header: {
                Label("Producto", systemImage: "cube.box.fill")
                    .foregroundColor(AppColors.primary)
            }

            // MARK: Cantidad
            Section {
                HStack {
                    Text("Unidades")
                        .font(AppFonts.body())
                    Spacer()
                    TextField("1", text: $viewModel.cantidad)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 80)
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)
                }
                if viewModel.selectedProduct != nil {
                    Text("Disponible: \(viewModel.stockDisponible) unidades")
                        .font(AppFonts.caption())
                        .foregroundColor(AppColors.textSecondary)
                }
            } header: {
                Label("Cantidad", systemImage: "number.circle.fill")
                    .foregroundColor(AppColors.primary)
            }

            // MARK: Resumen
            Section {
                HStack {
                    Text("Subtotal")
                        .font(AppFonts.body())
                    Spacer()
                    Text("S/ \(String(format: "%.2f", viewModel.subtotal))")
                        .foregroundColor(AppColors.textSecondary)
                }
                HStack {
                    Text("IGV (18%)")
                        .font(AppFonts.body())
                    Spacer()
                    Text("S/ \(String(format: "%.2f", viewModel.igv))")
                        .foregroundColor(AppColors.textSecondary)
                }
                HStack {
                    Text("TOTAL")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("S/ \(String(format: "%.2f", viewModel.total))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary)
                }
            } header: {
                Label("Resumen", systemImage: "list.bullet.rectangle.fill")
                    .foregroundColor(AppColors.primary)
            }

            // MARK: Error
            if let error = viewModel.errorMessage {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.danger)
                        Text(error)
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.danger)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.pageBackground)
        .navigationTitle("Nueva Venta")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar", action: onCancel)
                    .foregroundColor(AppColors.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Registrar") {
                    viewModel.save()
                }
                .fontWeight(.bold)
                .foregroundColor(viewModel.isFormValid ? AppColors.primary : AppColors.textTertiary)
                .disabled(!viewModel.isFormValid)
            }
        }
        .onAppear {
            viewModel.onSave = onSave
        }
    }

    // MARK: - Computed filters

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
