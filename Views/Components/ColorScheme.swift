import SwiftUI

// MARK: - Enhanced Color System for CalcBox

/// Centralized color management system with sophisticated palettes and gradients
struct CalcBoxColors {
    
    // MARK: - Category Color Definitions
    
    /// Enhanced color palette for calculator categories with gradient support
    enum CategoryColors {
        case financial, travel, health, utilities, education, lifestyle, time
        
        /// Primary color for the category
        var primary: Color {
            switch self {
            case .financial: return Color(hex: "10B981") // Emerald
            case .travel: return Color(hex: "3B82F6")    // Ocean Blue
            case .health: return Color(hex: "EF4444")    // Coral Red
            case .utilities: return Color(hex: "F59E0B") // Amber
            case .education: return Color(hex: "8B5CF6") // Deep Purple
            case .lifestyle: return Color(hex: "EC4899") // Rose
            case .time: return Color(hex: "6366F1")      // Indigo
            }
        }
        
        /// Secondary color for gradients and variations
        var secondary: Color {
            switch self {
            case .financial: return Color(hex: "059669") // Darker Emerald
            case .travel: return Color(hex: "1D4ED8")    // Darker Ocean Blue
            case .health: return Color(hex: "DC2626")    // Darker Coral Red
            case .utilities: return Color(hex: "D97706") // Darker Amber
            case .education: return Color(hex: "7C3AED") // Darker Purple
            case .lifestyle: return Color(hex: "DB2777") // Darker Rose
            case .time: return Color(hex: "3B82F6")      // Indigo-Cyan
            }
        }
        
        /// Light tint for backgrounds and subtle accents
        var light: Color {
            primary.opacity(0.1)
        }
        
        /// Medium opacity for hover states and secondary elements
        var medium: Color {
            primary.opacity(0.2)
        }
        
        /// Accent color for borders and highlights
        var accent: Color {
            primary.opacity(0.3)
        }
    }
    
    // MARK: - UI Element Colors
    
    /// Background colors for different contexts
    struct Backgrounds {
        static let primary = Color(.systemBackground)
        static let secondary = Color(.secondarySystemBackground)
        static let tertiary = Color(.tertiarySystemBackground)
        static let grouped = Color(.systemGroupedBackground)
        
        // Modern gradient backgrounds
        static let meshLight = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.8),
                Color(.secondarySystemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let meshDark = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.9),
                Color(.tertiarySystemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Text colors with enhanced contrast
    struct Text {
        static let primary = Color(.label)
        static let secondary = Color(.secondaryLabel)
        static let tertiary = Color(.tertiaryLabel)
        static let placeholder = Color(.placeholderText)
        
        // High contrast variants
        static let emphasis = Color(.label).opacity(0.95)
        static let subtle = Color(.secondaryLabel).opacity(0.8)
    }
    
    /// Surface colors for cards and containers
    struct Surface {
        static let card = Color(.systemBackground)
        static let elevated = Color(.secondarySystemBackground)
        static let pressed = Color(.tertiarySystemBackground)
        
        // Glass morphism inspired surfaces
        static let glass = Color.white.opacity(0.1)
        static let glassDark = Color.black.opacity(0.1)
    }
    
    /// Shadow definitions for depth and elevation
    struct Shadows {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity(0.2)
        
        // Colored shadows for category elements
        static func colored(_ category: CategoryColors, opacity: Double = 0.3) -> Color {
            category.primary.opacity(opacity)
        }
    }
}

// MARK: - Gradient Definitions

extension CalcBoxColors {
    
    /// Pre-defined gradients for consistent use across the app
    struct Gradients {
        
        // Category-specific gradients
        static func category(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [category.primary, category.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Subtle background gradients
        static func categoryBackground(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [
                    category.light,
                    category.light.opacity(0.3),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Button gradients
        static func button(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [
                    category.primary.opacity(0.9),
                    category.secondary.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        // Pressed button state
        static func buttonPressed(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [
                    category.secondary.opacity(0.9),
                    category.primary.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        // Result card gradients
        static func resultCard(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [
                    category.light,
                    category.medium.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Glass morphism gradient overlay
        static let glass = LinearGradient(
            colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let glassDark = LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Environment Key for Category Colors

struct CategoryColorKey: EnvironmentKey {
    static let defaultValue: CalcBoxColors.CategoryColors = .financial
}

extension EnvironmentValues {
    var categoryColor: CalcBoxColors.CategoryColors {
        get { self[CategoryColorKey.self] }
        set { self[CategoryColorKey.self] = newValue }
    }
}

// MARK: - View Modifiers for Consistent Styling

extension View {
    /// Apply category-themed styling to any view
    func categoryStyle(_ category: CalcBoxColors.CategoryColors) -> some View {
        self.environment(\.categoryColor, category)
    }
    
    /// Apply glass morphism effect
    func glassMorphism(intensity: Double = 1.0) -> some View {
        self
            .background(
                CalcBoxColors.Surface.glass
                    .opacity(intensity * 0.1)
                    .overlay(
                        CalcBoxColors.Gradients.glass
                            .opacity(intensity * 0.8)
                    )
            )
            .background(.ultraThinMaterial)
    }
    
    /// Apply category-themed shadow
    func categoryShadow(_ category: CalcBoxColors.CategoryColors, radius: CGFloat = 8) -> some View {
        self.shadow(
            color: CalcBoxColors.Shadows.colored(category, opacity: 0.2),
            radius: radius,
            x: 0,
            y: 2
        )
    }
    
    /// Apply layered shadow for depth
    func layeredShadow() -> some View {
        self
            .shadow(
                color: CalcBoxColors.Shadows.light,
                radius: 1,
                x: 0,
                y: 1
            )
            .shadow(
                color: CalcBoxColors.Shadows.medium,
                radius: 8,
                x: 0,
                y: 4
            )
    }
}