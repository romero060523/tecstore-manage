import SwiftUI

struct ClientFormView: View {
    @ObservedObject var viewModel: ClientFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {
            // MARK: Datos Personales
            Section("Datos Personales") {
                HStack {
                    Text("DNI")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("8 dígitos", text: $viewModel.dni)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 160)
                }

                HStack {
                    Text("Nombres")
                        .foregroundColor(.secondary)
                    TextField("Requerido", text: $viewModel.nombres)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Apellidos")
                        .foregroundColor(.secondary)
                    TextField("Requerido", text: $viewModel.apellidos)
                        .multilineTextAlignment(.trailing)
                }
            }

            // MARK: Contacto
            Section("Contacto") {
                HStack {
                    Text("+51")
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                    TextField("Teléfono (9 dígitos)", text: $viewModel.telefono)
                        .keyboardType(.phonePad)
                }

                HStack {
                    Text("Correo")
                        .foregroundColor(.secondary)
                    TextField("opcional@email.com", text: $viewModel.correo)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.trailing)
                }
            }

            // MARK: Dirección
            Section("Dirección") {
                TextField("Dirección (opcional)", text: $viewModel.direccion)
            }

            // MARK: Estado
            Section {
                Toggle("Cliente activo", isOn: $viewModel.estado)
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
        .navigationTitle(viewModel.isEditing ? "Editar Cliente" : "Nuevo Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar", action: onCancel)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    viewModel.save()
                }
                .fontWeight(.semibold)
                .disabled(!viewModel.isFormValid)
            }
        }
        .onAppear {
            viewModel.onSave = onSave
        }
    }
}
