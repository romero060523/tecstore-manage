import SwiftUI

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                // Logo
                Image(systemName: "storefront.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("TecStore Manager")
                    .font(.title).bold()

                Text("v1.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Sistema de gestión de inventarios, clientes y ventas para tiendas retail.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)

                Divider().padding(.horizontal, 40)

                // Info del proyecto
                VStack(spacing: 12) {
                    InfoRow(label: "Desarrollador", value: "Andy")
                    InfoRow(label: "Institución",   value: "TECSUP")
                    InfoRow(label: "Programa",      value: "Diseño y Desarrollo de Software")
                    InfoRow(label: "Ciclo",         value: "V")
                    InfoRow(label: "Año",           value: "2026")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Divider().padding(.horizontal, 40)

                // Tecnologías
                VStack(spacing: 10) {
                    Text("Tecnologías").font(.headline)
                    HStack(spacing: 12) {
                        TechBadge(name: "UIKit")
                        TechBadge(name: "SwiftUI")
                        TechBadge(name: "Core Data")
                    }
                    HStack(spacing: 12) {
                        TechBadge(name: "MapKit")
                        TechBadge(name: "Combine")
                        TechBadge(name: "MVVM")
                    }
                }

                Spacer().frame(height: 8)

                Text("© 2026 TECSUP — Todos los derechos reservados")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer().frame(height: 20)
            }
        }
        .navigationTitle("Acerca de")
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
    }
}

// MARK: - TechBadge

struct TechBadge: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(16)
    }
}
