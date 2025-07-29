import SwiftUI

struct CalculatorInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let suffix: String?
    
    init(
        title: String,
        value: Binding<String>,
        placeholder: String = "0",
        keyboardType: UIKeyboardType = .decimalPad,
        suffix: String? = nil
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.suffix = suffix
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(keyboardType)
                    .font(.title3)
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct CalculatorResultCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        color: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CalculatorButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return Color(.systemGray5)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            }
        }
    }
    
    init(
        title: String,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(style.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SegmentedPicker<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [(T, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}