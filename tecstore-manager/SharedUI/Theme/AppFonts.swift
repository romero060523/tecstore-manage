// Escala tipográfica de la aplicación.
import UIKit

struct AppFonts {
    static func title()   -> UIFont { .systemFont(ofSize: 28, weight: .bold) }
    static func heading() -> UIFont { .systemFont(ofSize: 20, weight: .semibold) }
    static func body()    -> UIFont { .systemFont(ofSize: 16, weight: .regular) }
    static func caption() -> UIFont { .systemFont(ofSize: 12, weight: .light) }
}
