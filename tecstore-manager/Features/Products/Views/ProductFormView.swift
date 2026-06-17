import SwiftUI

struct ProductFormView: View {
    @ObservedObject var viewModel: ProductFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Información básica
                VStack(alignment: .leading, spacing: 16) {
                    Label("Información básica", systemImage: "tag.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)

                    if viewModel.isEditing {
                        HStack {
                            Text("Código")
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(viewModel.codigo)
                                .font(AppFonts.mono())
                                .foregroundColor(AppColors.textPrimary)
                        }
                        Divider()
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Código")
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.textSecondary)
                            CustomTextField(
                                placeholder: "Auto-generado (PROD-XXXX)",
                                text: $viewModel.codigo,
                                autocapitalization: .characters
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nombre *")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        CustomTextField(placeholder: "Nombre del producto", text: $viewModel.nombre)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Categoría")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        Picker("Categoría", selection: $viewModel.categoria) {
                            ForEach(viewModel.categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.primary)
                        .padding(.vertical, 4)
                        .overlay(
                            Rectangle().frame(height: 1)
                                .foregroundColor(AppColors.textTertiary.opacity(0.4)),
                            alignment: .bottom
                        )
                    }
                }
                .cardStyle()

                // MARK: Precio y Stock
                VStack(alignment: .leading, spacing: 16) {
                    Label("Precio y stock", systemImage: "dollarsign.circle.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Precio (S/) *")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        HStack(spacing: 8) {
                            Text("S/")
                                .font(AppFonts.headline())
                                .foregroundColor(AppColors.primary)
                            CustomTextField(
                                placeholder: "0.00",
                                text: $viewModel.precio,
                                keyboardType: .decimalPad
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stock inicial *")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        HStack(spacing: 8) {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 15))
                            CustomTextField(
                                placeholder: "0",
                                text: $viewModel.stock,
                                keyboardType: .numberPad
                            )
                        }
                    }
                }
                .cardStyle()

                // MARK: Estado
                HStack {
                    Label("Producto activo", systemImage: "checkmark.seal.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Toggle("", isOn: $viewModel.estado)
                        .tint(AppColors.primary)
                }
                .cardStyle(padding: 14)

                // MARK: Error
                if let error = viewModel.errorMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.danger)
                        Text(error)
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.danger)
                    }
                    .cardStyle(padding: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.danger.opacity(0.3), lineWidth: 1)
                    )
                }

                // MARK: Guardar
                Button("Guardar Producto") { viewModel.save() }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.isFormValid))
                    .disabled(!viewModel.isFormValid)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle(viewModel.isEditing ? "Editar Producto" : "Nuevo Producto")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar", action: onCancel)
                    .foregroundColor(AppColors.primary)
            }
        }
        .onAppear {
            viewModel.onSave = onSave
        }
    }
}
