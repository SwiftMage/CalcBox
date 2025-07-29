import SwiftUI

struct CalculatorView<Content: View>: View {
    let title: String
    let description: String
    let content: Content
    
    init(
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Content
                content
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

struct NumberFormatter {
    static let currency: Foundation.NumberFormatter = {
        let formatter = Foundation.NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let decimal: Foundation.NumberFormatter = {
        let formatter = Foundation.NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let percent: Foundation.NumberFormatter = {
        let formatter = Foundation.NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func formatCurrency(_ value: Double) -> String {
        currency.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    static func formatDecimal(_ value: Double) -> String {
        decimal.string(from: NSNumber(value: value)) ?? "0"
    }
    
    static func formatPercent(_ value: Double) -> String {
        percent.string(from: NSNumber(value: value / 100)) ?? "0%"
    }
}