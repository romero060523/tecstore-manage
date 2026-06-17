import SwiftUI

struct AppColors {

    // MARK: - Paleta principal — Azul índigo premium

    static let primary      = Color(red: 0.22, green: 0.35, blue: 0.95)
    static let primaryLight = Color(red: 0.60, green: 0.70, blue: 0.98)
    static let primaryDark  = Color(red: 0.14, green: 0.22, blue: 0.70)

    // MARK: - Gradientes

    static let gradientPrimary = LinearGradient(
        colors: [Color(red: 0.22, green: 0.35, blue: 0.95),
                 Color(red: 0.45, green: 0.25, blue: 0.95)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientSuccess = LinearGradient(
        colors: [Color(red: 0.18, green: 0.75, blue: 0.55),
                 Color(red: 0.10, green: 0.60, blue: 0.45)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientWarning = LinearGradient(
        colors: [Color(red: 0.98, green: 0.65, blue: 0.18),
                 Color(red: 0.95, green: 0.45, blue: 0.10)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientPurple = LinearGradient(
        colors: [Color(red: 0.65, green: 0.25, blue: 0.95),
                 Color(red: 0.45, green: 0.15, blue: 0.80)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // MARK: - Semánticos

    static let success = Color(red: 0.18, green: 0.75, blue: 0.55)
    static let warning = Color(red: 0.98, green: 0.65, blue: 0.18)
    static let danger  = Color(red: 0.95, green: 0.28, blue: 0.28)
    static let purple  = Color(red: 0.65, green: 0.25, blue: 0.95)

    // MARK: - Fondos

    static let cardBackground = Color(.systemBackground)
    static let pageBackground = Color(.systemGroupedBackground)

    // MARK: - Texto

    static let textPrimary   = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary  = Color(.tertiaryLabel)
}
