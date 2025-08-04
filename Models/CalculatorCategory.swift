import Foundation
import SwiftUI

// MARK: - CalcBox Color System (Temporary Integration)

/// Centralized color management system for CalcBox
struct CalcBoxColors {
    
    // MARK: - Category Colors
    
    enum CategoryColors {
        case financial, travel, health, utilities, education, lifestyle, time
        
        var primary: Color {
            switch self {
            case .financial: return Color(hex: "10B981") // Emerald
            case .travel: return Color(hex: "3B82F6")    // Ocean Blue
            case .health: return Color(hex: "F59E0B")    // Golden Yellow
            case .utilities: return Color(hex: "8B5CF6") // Violet
            case .education: return Color(hex: "EC4899") // Pink
            case .lifestyle: return Color(hex: "06B6D4") // Cyan
            case .time: return Color(hex: "EF4444")      // Red
            }
        }
        
        var secondary: Color {
            switch self {
            case .financial: return Color(hex: "059669") // Darker emerald
            case .travel: return Color(hex: "1D4ED8")    // Darker blue
            case .health: return Color(hex: "D97706")    // Darker yellow
            case .utilities: return Color(hex: "7C3AED") // Darker violet
            case .education: return Color(hex: "DB2777") // Darker pink
            case .lifestyle: return Color(hex: "0891B2") // Darker cyan
            case .time: return Color(hex: "DC2626")      // Darker red
            }
        }
        
        var light: Color {
            return primary.opacity(0.1)
        }
        
        var medium: Color {
            return primary.opacity(0.3)
        }
        
        var accent: Color {
            return primary.opacity(0.8)
        }
    }
    
    // MARK: - Surface Colors
    
    struct Surface {
        static let primary = Color(.systemBackground)
        static let secondary = Color(.secondarySystemBackground)
        static let elevated = Color(.tertiarySystemBackground)
        static let card = Color(.systemBackground)
        static let glass = Color.white.opacity(0.1)
    }
    
    // MARK: - Text Colors
    
    struct Text {
        static let primary = Color(.label)
        static let secondary = Color(.secondaryLabel)
        static let tertiary = Color(.tertiaryLabel)
    }
    
    // MARK: - Background Colors
    
    struct Backgrounds {
        static let primary = Color(.systemBackground)
        static let secondary = Color(.secondarySystemBackground)
        static let meshLight = LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground).opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        static func category(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [category.primary, category.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func categoryBackground(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [category.light, Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func button(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [category.primary, category.secondary],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        static func resultCard(_ category: CategoryColors) -> LinearGradient {
            LinearGradient(
                colors: [
                    category.primary.opacity(0.2),
                    category.secondary.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Color Extensions

extension Color {
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

// MARK: - Essential Gradient Styles (Temporary Integration)

struct GradientStyles {
    /// Glass card overlay with subtle gradients
    struct GlassCardOverlay: View {
        let category: CalcBoxColors.CategoryColors
        let intensity: Double
        
        init(category: CalcBoxColors.CategoryColors, intensity: Double = 1.0) {
            self.category = category
            self.intensity = intensity
        }
        
        var body: some View {
            ZStack {
                // Base glass effect
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2 * intensity),
                        Color.white.opacity(0.05 * intensity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Category accent
                LinearGradient(
                    colors: [
                        category.primary.opacity(0.1 * intensity),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .center
                )
            }
        }
    }
    
    /// Modern button gradient with hover effects
    struct ModernButtonGradient: View {
        let category: CalcBoxColors.CategoryColors
        let isPressed: Bool
        let isDisabled: Bool
        
        var body: some View {
            Group {
                if isDisabled {
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else if isPressed {
                    LinearGradient(
                        colors: [
                            category.secondary.opacity(0.9),
                            category.primary.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            colors: [
                                category.primary.opacity(0.8),
                                category.secondary.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        // Shine effect
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            }
        }
    }
}

// MARK: - View Extensions for Shadows and Effects

extension View {
    /// Apply layered shadow effect
    func layeredShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    /// Apply category-specific shadow
    func categoryShadow(_ category: CalcBoxColors.CategoryColors, radius: CGFloat = 8) -> some View {
        self.shadow(
            color: category.primary.opacity(0.3),
            radius: radius,
            x: 0,
            y: radius / 2
        )
    }
}

enum CalculatorCategory: String, CaseIterable {
    case financial = "Financial"
    case travel = "Travel"
    case health = "Health"
    case utilities = "Utilities"
    case education = "Education"
    case lifestyle = "Lifestyle"
    case time = "Time & Date"
    
    var icon: String {
        switch self {
        case .financial: return "dollarsign.circle.fill"
        case .travel: return "car.fill"
        case .health: return "heart.fill"
        case .utilities: return "bolt.fill"
        case .education: return "graduationcap.fill"
        case .lifestyle: return "person.fill"
        case .time: return "clock.fill"
        }
    }
    
    /// Enhanced color system with gradient support
    var colorScheme: CalcBoxColors.CategoryColors {
        switch self {
        case .financial: return .financial
        case .travel: return .travel
        case .health: return .health
        case .utilities: return .utilities
        case .education: return .education
        case .lifestyle: return .lifestyle
        case .time: return .time
        }
    }
    
    /// Legacy color property for backward compatibility
    var color: Color {
        return colorScheme.primary
    }
    
    /// Primary gradient for the category
    var gradient: LinearGradient {
        return CalcBoxColors.Gradients.category(colorScheme)
    }
    
    /// Background gradient for subtle category theming
    var backgroundGradient: LinearGradient {
        return CalcBoxColors.Gradients.categoryBackground(colorScheme)
    }
    
    /// Button gradient for category-themed buttons
    var buttonGradient: LinearGradient {
        return CalcBoxColors.Gradients.button(colorScheme)
    }
    
    /// Light tint color for backgrounds
    var lightTint: Color {
        return colorScheme.light
    }
    
    /// Medium opacity color for hover states
    var mediumTint: Color {
        return colorScheme.medium
    }
    
    /// Accent color for borders and highlights
    var accentColor: Color {
        return colorScheme.accent
    }
    
    /// Themed description for the category
    var themeDescription: String {
        switch self {
        case .financial: return "Prosperity & Growth"
        case .travel: return "Adventure & Freedom"
        case .health: return "Vitality & Wellness"
        case .utilities: return "Energy & Efficiency"
        case .education: return "Wisdom & Knowledge"
        case .lifestyle: return "Personal & Style"
        case .time: return "Precision & Flow"
        }
    }
}