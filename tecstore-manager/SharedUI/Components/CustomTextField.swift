import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .font(AppFonts.body())
        .padding(.vertical, 4)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.textTertiary.opacity(0.4)),
            alignment: .bottom
        )
    }
}
