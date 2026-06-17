import SwiftUI

struct AppFonts {
    static func largeTitle() -> Font { .system(size: 32, weight: .bold,    design: .rounded) }
    static func title()      -> Font { .system(size: 24, weight: .bold,    design: .rounded) }
    static func title2()     -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
    static func headline()   -> Font { .system(size: 16, weight: .semibold, design: .rounded) }
    static func body()       -> Font { .system(size: 15, weight: .regular,  design: .default) }
    static func caption()    -> Font { .system(size: 12, weight: .medium,   design: .rounded) }
    static func caption2()   -> Font { .system(size: 11, weight: .regular,  design: .rounded) }
    static func mono()       -> Font { .system(size: 13, weight: .medium,   design: .monospaced) }
}
