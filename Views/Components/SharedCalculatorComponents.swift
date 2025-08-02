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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}