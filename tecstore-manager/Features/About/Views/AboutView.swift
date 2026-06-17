import SwiftUI

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Gradient header
                ZStack {
                    AppColors.gradientPrimary
                    VStack(spacing: 10) {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                        Text("TecStore Manager")
                            .font(AppFonts.largeTitle())
                            .foregroundColor(.white)
                        Text("v1.0")
                            .font(AppFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 14).padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.top, 24)
                }
                .frame(height: 220)

                VStack(spacing: 20) {

                    // MARK: Descripción
                    Text("Sistema de gestión de inventarios, clientes y ventas para tiendas retail.")
                        .font(AppFonts.body())
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    // MARK: Info del proyecto
                    VStack(spacing: 0) {
                        InfoRow(
                            label: "Desarrollador",
                            value: "Andy",
                            icon: "person.fill",
                            color: AppColors.primary
                        )
                        Divider().padding(.leading, 44)
                        InfoRow(
                            label: "Institución",
                            value: "TECSUP",
                            icon: "building.columns.fill",
                            color: AppColors.success
                        )
                        Divider().padding(.leading, 44)
                        InfoRow(
                            label: "Programa",
                            value: "DDS",
                            icon: "laptopcomputer",
                            color: AppColors.warning
                        )
                        Divider().padding(.leading, 44)
                        InfoRow(
                            label: "Ciclo",
                            value: "V",
                            icon: "graduationcap.fill",
                            color: AppColors.purple
                        )
                        Divider().padding(.leading, 44)
                        InfoRow(
                            label: "Año",
                            value: "2026",
                            icon: "calendar",
                            color: AppColors.primary
                        )
                    }
                    .cardStyle(padding: 0)

                    // MARK: Tecnologías
                    VStack(spacing: 14) {
                        SectionHeader(title: "Tecnologías", icon: "wrench.and.screwdriver.fill")
                        HStack(spacing: 10) {
                            TechBadge(name: "UIKit",      gradient: AppColors.gradientPrimary)
                            TechBadge(name: "SwiftUI",    gradient: AppColors.gradientSuccess)
                            TechBadge(name: "Core Data",  gradient: AppColors.gradientWarning)
                        }
                        HStack(spacing: 10) {
                            TechBadge(name: "MapKit",     gradient: AppColors.gradientPurple)
                            TechBadge(name: "Combine",    gradient: AppColors.gradientPrimary)
                            TechBadge(name: "MVVM",       gradient: AppColors.gradientSuccess)
                        }
                    }
                    .cardStyle()

                    Text("© 2026 TECSUP — Todos los derechos reservados")
                        .font(AppFonts.caption2())
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(label)
                .font(AppFonts.body())
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - TechBadge

struct TechBadge: View {
    let name: String
    let gradient: LinearGradient

    var body: some View {
        Text(name)
            .font(AppFonts.caption())
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(gradient)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
    }
}
