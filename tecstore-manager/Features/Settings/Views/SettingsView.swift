import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showLogoutAlert = false

    var body: some View {
        List {
            // MARK: Perfil
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Text(String(viewModel.currentUser.prefix(2)).uppercased())
                            .font(.title2).bold()
                            .foregroundColor(.blue)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.currentUser).font(.headline)
                        Text("Administrador")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // MARK: Base de datos
            Section("Base de Datos") {
                HStack {
                    Label("Productos", systemImage: "cube.box.fill")
                    Spacer()
                    Text("\(viewModel.totalProductos)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Label("Clientes", systemImage: "person.2.fill")
                    Spacer()
                    Text("\(viewModel.totalClientes)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Label("Ventas", systemImage: "cart.fill")
                    Spacer()
                    Text("\(viewModel.totalVentas)")
                        .foregroundColor(.secondary)
                }
            }

            // MARK: Herramientas
            Section("Herramientas") {
                Button {
                    viewModel.onNavigateToReports?()
                } label: {
                    Label("Reportes de Ventas", systemImage: "chart.bar.fill")
                }
                .foregroundColor(.primary)
            }

            // MARK: Información
            Section("Información") {
                Button {
                    viewModel.onNavigateToAbout?()
                } label: {
                    Label("Acerca de", systemImage: "info.circle.fill")
                }
                .foregroundColor(.primary)
            }

            // MARK: Sesión
            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Configuración")
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar Sesión", role: .destructive) { viewModel.logout() }
        } message: {
            Text("¿Estás seguro que deseas cerrar sesión?")
        }
        .onAppear { viewModel.loadStats() }
    }
}
