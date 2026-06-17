import SwiftUI

struct ClientFormView: View {
    @ObservedObject var viewModel: ClientFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Datos Personales
                VStack(alignment: .leading, spacing: 16) {
                    Label("Datos Personales", systemImage: "person.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("DNI * (8 dígitos)")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        CustomTextField(
                            placeholder: "12345678",
                            text: $viewModel.dni,
                            keyboardType: .numberPad,
                            autocapitalization: .never
                        )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nombres *")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        CustomTextField(placeholder: "Nombres", text: $viewModel.nombres)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apellidos *")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        CustomTextField(placeholder: "Apellidos", text: $viewModel.apellidos)
                    }
                }
                .cardStyle()

                // MARK: Contacto
                VStack(alignment: .leading, spacing: 16) {
                    Label("Contacto", systemImage: "phone.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Teléfono (opcional)")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        HStack(spacing: 8) {
                            Text("+51")
                                .font(AppFonts.body())
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.trailing, 2)
                            CustomTextField(
                                placeholder: "987654321",
                                text: $viewModel.telefono,
                                keyboardType: .phonePad,
                                autocapitalization: .never
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Correo electrónico (opcional)")
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.textSecondary)
                        CustomTextField(
                            placeholder: "correo@ejemplo.com",
                            text: $viewModel.correo,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                    }
                }
                .cardStyle()

                // MARK: Dirección
                VStack(alignment: .leading, spacing: 12) {
                    Label("Dirección", systemImage: "map.fill")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)
                    CustomTextField(placeholder: "Dirección (opcional)", text: $viewModel.direccion)
                }
                .cardStyle()

                // MARK: Estado
                HStack {
                    Label("Cliente activo", systemImage: "checkmark.seal.fill")
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
                Button("Guardar Cliente") { viewModel.save() }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.isFormValid))
                    .disabled(!viewModel.isFormValid)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle(viewModel.isEditing ? "Editar Cliente" : "Nuevo Cliente")
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
