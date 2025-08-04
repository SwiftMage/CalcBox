import SwiftUI

struct QuickActionButtonRow: View {
    let onExample: () -> Void
    let onClear: () -> Void
    let onInfo: () -> Void
    let onShare: (() -> Void)?
    let showShare: Bool
    
    init(
        onExample: @escaping () -> Void,
        onClear: @escaping () -> Void,
        onInfo: @escaping () -> Void,
        onShare: (() -> Void)? = nil,
        showShare: Bool = false
    ) {
        self.onExample = onExample
        self.onClear = onClear
        self.onInfo = onInfo
        self.onShare = onShare
        self.showShare = showShare
    }
    
    var body: some View {
        HStack(spacing: 8) {
            QuickActionButton(
                icon: "wand.and.stars.inverse",
                title: "Example",
                color: .blue,
                action: onExample
            )
            
            QuickActionButton(
                icon: "trash",
                title: "Clear",
                color: .red,
                action: onClear
            )
            
            QuickActionButton(
                icon: "info.circle",
                title: "Info",
                color: .gray,
                action: onInfo
            )
            
            if showShare, let shareAction = onShare {
                QuickActionButton(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    color: .green,
                    action: shareAction
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(CalcBoxColors.Text.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background {
                ZStack {
                    // Base background with gradient
                    LinearGradient(
                        colors: [
                            color.opacity(0.15),
                            color.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Glass overlay
                    CalcBoxColors.Surface.glass
                        .opacity(0.3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .shadow(
                color: color.opacity(0.2),
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0.0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    let accentColor: Color?
    @State private var animate = false
    
    init(title: String, content: String, accentColor: Color? = nil) {
        self.title = title
        self.content = content
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if let accentColor = accentColor {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animate ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(CalcBoxColors.Text.primary)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(CalcBoxColors.Text.secondary)
                .lineSpacing(2)
        }
        .padding(20)
        .background {
            ZStack {
                // Base background
                CalcBoxColors.Surface.card
                
                // Accent gradient if provided
                if let accentColor = accentColor {
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Glass overlay
                CalcBoxColors.Surface.glass
                    .opacity(0.3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    accentColor?.opacity(0.2) ?? Color.gray.opacity(0.2),
                    lineWidth: 1
                )
        )
        .layeredShadow()
        .onAppear {
            animate = true
        }
    }
}