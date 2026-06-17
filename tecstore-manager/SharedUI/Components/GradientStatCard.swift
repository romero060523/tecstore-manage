import SwiftUI

struct GradientStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                if let subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption())
                        .foregroundColor(.white.opacity(0.75))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            Spacer()
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(AppFonts.caption())
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .frame(height: 110)
        .background(gradient)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}
