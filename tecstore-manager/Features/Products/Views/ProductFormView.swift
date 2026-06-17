import SwiftUI

struct ProductFormView: View {
    @ObservedObject var viewModel: ProductFormViewModel
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Form {
            // MARK: Información básica
            Section("Información básica") {
                HStack {
                    Text("Código")
                        .foregroundColor(.secondary)
                    TextField(
                        viewModel.isEditing ? viewModel.codigo : "Auto (PROD-XXXX)",
                        text: $viewModel.codigo
                    )
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                }

                HStack {
                    Text("Nombre")
                        .foregroundColor(.secondary)
                    TextField("Requerido", text: $viewModel.nombre)
                        .multilineTextAlignment(.trailing)
                }

                Picker("Categoría", selection: $viewModel.categoria) {
                    ForEach(viewModel.categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }

            // MARK: Precio y Stock
            Section("Precio y stock") {
                HStack {
                    Text("Precio (S/)")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("0.00", text: $viewModel.precio)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }

                HStack {
                    Text("Stock")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("0", text: $viewModel.stock)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
            }

            // MARK: Estado
            Section {
                Toggle("Producto activo", isOn: $viewModel.estado)
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
        .navigationTitle(viewModel.isEditing ? "Editar Producto" : "Nuevo Producto")
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
