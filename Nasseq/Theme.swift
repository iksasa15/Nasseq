import SwiftUI

// MARK: - Colors
extension Color {
    static let nasseqTeal = Color(red: 92/255, green: 153/255, blue: 153/255)
    static let nasseqTealLight = Color(red: 120/255, green: 180/255, blue: 180/255)
    static let nasseqTealDark = Color(red: 70/255, green: 120/255, blue: 120/255)
    
    // Additional palette
    static let nasseqBackground = Color(UIColor.systemBackground)
    static let nasseqSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let nasseqAccent = Color.nasseqTeal
}

// MARK: - Fonts
extension Font {
    // Cairo font with SF Arabic fallback
    static func cairo(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Try to use Cairo font if available
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "Cairo-Bold"
        case .semibold:
            fontName = "Cairo-SemiBold"
        case .medium:
            fontName = "Cairo-Medium"
        case .light, .thin, .ultraLight:
            fontName = "Cairo-Light"
        default:
            fontName = "Cairo-Regular"
        }
        
        // Check if Cairo is available, otherwise use system
        if UIFont(name: fontName, size: size) != nil {
            return .custom(fontName, size: size)
        } else {
            // Fallback to SF Arabic (system font)
            return .system(size: size, weight: weight, design: .default)
        }
    }
    
    // Predefined text styles
    static let nasseqTitle = Font.cairo(28, weight: .bold)
    static let nasseqHeadline = Font.cairo(20, weight: .semibold)
    static let nasseqBody = Font.cairo(16, weight: .regular)
    static let nasseqCaption = Font.cairo(14, weight: .regular)
    static let nasseqSmall = Font.cairo(12, weight: .regular)
}

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
}
