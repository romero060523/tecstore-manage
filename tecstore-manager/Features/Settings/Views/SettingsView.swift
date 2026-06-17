import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showLogoutAlert = false

    var body: some View {
        List {

            // MARK: Perfil — gradient header
            Section {
                ZStack(alignment: .bottomLeading) {
                    AppColors.gradientPrimary
                        .cornerRadius(16)
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 64, height: 64)
                            Text(String(viewModel.currentUser.prefix(2)).uppercased())
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentUser)
                                .font(AppFonts.title2())
                                .foregroundColor(.white)
                            Text("Administrador")
                                .font(AppFonts.caption())
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    .padding(20)
                }
                .frame(height: 130)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // MARK: Base de datos
            Section("Base de Datos") {
                HStack {
                    Label("Productos", systemImage: "cube.box.fill")
                        .foregroundColor(AppColors.primary)
                    Spacer()
                    Text("\(viewModel.totalProductos)")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textSecondary)
                }
                HStack {
                    Label("Clientes", systemImage: "person.2.fill")
                        .foregroundColor(AppColors.success)
                    Spacer()
                    Text("\(viewModel.totalClientes)")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textSecondary)
                }
                HStack {
                    Label("Ventas", systemImage: "cart.fill")
                        .foregroundColor(AppColors.warning)
                    Spacer()
                    Text("\(viewModel.totalVentas)")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // MARK: Herramientas
            Section("Herramientas") {
                Button {
                    viewModel.onNavigateToReports?()
                } label: {
                    HStack {
                        Label("Reportes de Ventas", systemImage: "chart.bar.fill")
                            .foregroundColor(AppColors.purple)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .foregroundColor(.primary)
            }

            // MARK: Información
            Section("Información") {
                Button {
                    viewModel.onNavigateToAbout?()
                } label: {
                    HStack {
                        Label("Acerca de TecStore", systemImage: "info.circle.fill")
                            .foregroundColor(AppColors.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .foregroundColor(.primary)
            }

            // MARK: Sesión
            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar Sesión")
                            .font(AppFonts.headline())
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(AppColors.danger.opacity(0.08))
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.pageBackground)
        .navigationTitle("Configuración")
        .navigationBarTitleDisplayMode(.large)
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar Sesión", role: .destructive) { viewModel.logout() }
        } message: {
            Text("¿Estás seguro que deseas cerrar sesión?")
        }
        .onAppear { viewModel.loadStats() }
    }
}
