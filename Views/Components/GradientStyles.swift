import SwiftUI

// MARK: - Advanced Gradient Styles and Animations

/// Collection of reusable gradient styles and visual effects for CalcBox
struct GradientStyles {
    
    // MARK: - Animated Gradients
    
    /// Animated gradient that shifts colors based on state
    struct AnimatedGradient: View {
        let colors: [Color]
        let startPoint: UnitPoint
        let endPoint: UnitPoint
        @State private var animationOffset: CGFloat = 0
        
        var body: some View {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .hueRotation(.degrees(animationOffset))
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animationOffset = 30
                }
            }
        }
    }
    
    /// Shimmer effect for loading states
    struct ShimmerGradient: View {
        @State private var phase = 0.0
        let duration: Double
        
        init(duration: Double = 1.5) {
            self.duration = duration
        }
        
        var body: some View {
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.8),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(phase))
            .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: phase)
            .onAppear { phase = 360 }
        }
    }
    
    // MARK: - Complex Background Gradients
    
    /// Mesh gradient background for modern app feel
    struct MeshBackground: View {
        let category: CalcBoxColors.CategoryColors
        @State private var animate = false
        
        var body: some View {
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        CalcBoxColors.Backgrounds.primary,
                        CalcBoxColors.Backgrounds.secondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Floating color orbs
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                category.primary.opacity(0.3),
                                category.primary.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: animate ? 100 : -100, y: animate ? -50 : 50)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                category.secondary.opacity(0.2),
                                category.secondary.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 200, height: 200)
                    .offset(x: animate ? -80 : 80, y: animate ? 100 : -100)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            }
            .onAppear { animate = true }
        }
    }
    
    // MARK: - Card Gradient Overlays
    
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
                
                // Bottom highlight
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.1 * intensity)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    /// Success/Error state gradient overlay
    struct StateGradientOverlay: View {
        enum State {
            case success, warning, error, neutral
            
            var colors: [Color] {
                switch self {
                case .success:
                    return [Color.green.opacity(0.2), Color.green.opacity(0.05)]
                case .warning:
                    return [Color.orange.opacity(0.2), Color.orange.opacity(0.05)]
                case .error:
                    return [Color.red.opacity(0.2), Color.red.opacity(0.05)]
                case .neutral:
                    return [Color.gray.opacity(0.1), Color.clear]
                }
            }
        }
        
        let state: State
        @State private var pulseIntensity: Double = 1.0
        
        var body: some View {
            LinearGradient(
                colors: state.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(pulseIntensity)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseIntensity)
            .onAppear {
                if state != .neutral {
                    pulseIntensity = 0.6
                }
            }
        }
    }
    
    // MARK: - Button Gradient Effects
    
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
    
    // MARK: - Progress and Loading Gradients
    
    /// Animated progress gradient
    struct ProgressGradient: View {
        let category: CalcBoxColors.CategoryColors
        let progress: Double
        @State private var animateProgress = false
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    category.primary,
                                    category.secondary,
                                    category.primary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    // Shimmer effect
                    if progress > 0 && progress < 1.0 {
                        ShimmerGradient()
                            .frame(width: geometry.size.width * min(progress, 1.0))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(0.6)
                    }
                }
            }
        }
    }
    
    /// Pulsing loading gradient
    struct PulsingGradient: View {
        let category: CalcBoxColors.CategoryColors
        @State private var pulsePhase = 0.0
        
        var body: some View {
            LinearGradient(
                colors: [
                    category.primary.opacity(0.3),
                    category.secondary.opacity(0.6),
                    category.primary.opacity(0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(0.5 + 0.5 * sin(pulsePhase))
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulsePhase)
            .onAppear { pulsePhase = .pi * 2 }
        }
    }
}

// MARK: - View Extensions for Gradient Effects

extension View {
    /// Apply animated mesh background
    func meshBackground(_ category: CalcBoxColors.CategoryColors) -> some View {
        self.background(GradientStyles.MeshBackground(category: category))
    }
    
    /// Apply glass card overlay
    func glassCard(category: CalcBoxColors.CategoryColors, intensity: Double = 1.0) -> some View {
        self.overlay(
            GradientStyles.GlassCardOverlay(category: category, intensity: intensity)
        )
    }
    
    /// Apply state-based gradient overlay
    func stateOverlay(_ state: GradientStyles.StateGradientOverlay.State) -> some View {
        self.overlay(GradientStyles.StateGradientOverlay(state: state))
    }
    
    /// Apply shimmer loading effect
    func shimmer() -> some View {
        self.overlay(
            GradientStyles.ShimmerGradient()
                .opacity(0.6)
        )
    }
    
    /// Apply modern button gradient with press states
    func modernButtonStyle(
        category: CalcBoxColors.CategoryColors,
        isPressed: Bool = false,
        isDisabled: Bool = false
    ) -> some View {
        self.background(
            GradientStyles.ModernButtonGradient(
                category: category,
                isPressed: isPressed,
                isDisabled: isDisabled
            )
        )
    }
}

// MARK: - Custom Button Styles Using Gradients

struct ModernGradientButtonStyle: ButtonStyle {
    let category: CalcBoxColors.CategoryColors
    let isDisabled: Bool
    
    init(category: CalcBoxColors.CategoryColors, isDisabled: Bool = false) {
        self.category = category
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                GradientStyles.ModernButtonGradient(
                    category: category,
                    isPressed: configuration.isPressed,
                    isDisabled: isDisabled
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .categoryShadow(category, radius: configuration.isPressed ? 4 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .disabled(isDisabled)
    }
}

// MARK: - Gradient Animation Presets

extension Animation {
    /// Smooth gradient transition animation
    static let gradientTransition = Animation.easeInOut(duration: 0.3)
    
    /// Pulsing animation for loading states
    static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    
    /// Shimmer animation for loading effects
    static let shimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
    
    /// Gentle floating animation for background elements
    static let float = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
}