import SwiftUI
import MapKit

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

                // MARK: Ubicación
                VStack(alignment: .leading, spacing: 12) {
                    Label("Ubicación del Cliente", systemImage: "mappin.and.ellipse")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.primary)

                    if viewModel.isLoadingLocation {
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.9)
                            Text("Obteniendo ubicación GPS...")
                                .font(AppFonts.body())
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary.opacity(0.05))
                        .cornerRadius(12)

                    } else if let lat = viewModel.latitud,
                              let lon = viewModel.longitud {
                        VStack(spacing: 8) {
                            MapSnapshotView(latitude: lat, longitude: lon)
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                                )

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                    .font(.system(size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    if let dir = viewModel.ubicacionDireccion {
                                        Text(dir)
                                            .font(AppFonts.caption())
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    Text(String(format: "%.6f, %.6f", lat, lon))
                                        .font(AppFonts.caption2())
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                            }

                            HStack(spacing: 8) {
                                Button {
                                    viewModel.captureCurrentLocation()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Actualizar")
                                    }
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(AppColors.primary.opacity(0.08))
                                    .cornerRadius(8)
                                }

                                Button {
                                    viewModel.clearLocation()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash")
                                        Text("Eliminar")
                                    }
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.danger)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(AppColors.danger.opacity(0.08))
                                    .cornerRadius(8)
                                }
                            }
                        }

                    } else {
                        VStack(spacing: 10) {
                            Button {
                                viewModel.captureCurrentLocation()
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.primary.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "location.fill")
                                            .foregroundColor(AppColors.primary)
                                            .font(.system(size: 16))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Usar mi ubicación actual")
                                            .font(AppFonts.headline())
                                            .foregroundColor(AppColors.primary)
                                        Text("Captura las coordenadas GPS ahora")
                                            .font(AppFonts.caption2())
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .padding(12)
                                .background(AppColors.primary.opacity(0.06))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primary.opacity(0.15), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            Text("La ubicación es opcional. Puedes completar la dirección manualmente en el campo anterior.")
                                .font(AppFonts.caption2())
                                .foregroundColor(AppColors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    if let error = viewModel.locationError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppColors.warning)
                                .font(.caption)
                            Text(error)
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.warning)
                        }
                        .padding(10)
                        .background(AppColors.warning.opacity(0.08))
                        .cornerRadius(8)
                    }
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
