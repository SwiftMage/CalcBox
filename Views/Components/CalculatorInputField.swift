import SwiftUI
import UIKit


// MARK: - Keyboard Toolbar TextField

struct KeyboardToolbarTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?
    var showPreviousButton: Bool = true
    var showNextButton: Bool = true
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .decimalPad
        textField.font = UIFont.preferredFont(forTextStyle: .title2)
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Create toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.systemBlue
        toolbar.sizeToFit()
        
        var items: [UIBarButtonItem] = []
        
        if showPreviousButton {
            let previousButton = UIBarButtonItem(title: "Previous", style: .plain, target: context.coordinator, action: #selector(Coordinator.previousPressed))
            items.append(previousButton)
        }
        
        if showNextButton {
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: context.coordinator, action: #selector(Coordinator.nextPressed))
            items.append(nextButton)
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items.append(flexSpace)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.donePressed))
        items.append(doneButton)
        
        toolbar.setItems(items, animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
        
        // Store references for coordinator
        context.coordinator.textField = textField
        context.coordinator.onPrevious = onPrevious
        context.coordinator.onNext = onNext
        context.coordinator.onDone = onDone
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        context.coordinator.onPrevious = onPrevious
        context.coordinator.onNext = onNext
        context.coordinator.onDone = onDone
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: KeyboardToolbarTextField
        var textField: UITextField?
        var onPrevious: (() -> Void)?
        var onNext: (() -> Void)?
        var onDone: (() -> Void)?
        
        init(_ parent: KeyboardToolbarTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Allow empty string
            if newText.isEmpty {
                parent.text = newText
                return true
            }
            
            // Validate decimal input
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            
            // Allow only one decimal point
            let decimalCount = newText.components(separatedBy: ".").count - 1
            if decimalCount > 1 {
                return false
            }
            
            parent.text = newText
            return true
        }
        
        @objc func previousPressed() {
            onPrevious?()
        }
        
        @objc func nextPressed() {
            onNext?()
        }
        
        @objc func donePressed() {
            textField?.resignFirstResponder()
            onDone?()
        }
    }
}

// MARK: - Enhanced Input Field Components

struct ModernInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let prefix: String?
    let suffix: String?
    let icon: String
    let color: Color
    let keyboardType: UIKeyboardType
    let helpText: String?
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?
    var showPreviousButton: Bool = true
    var showNextButton: Bool = true
    
    private var fieldId: String {
        "input-\(title.replacingOccurrences(of: " ", with: "-").lowercased())"
    }
    
    init(
        title: String,
        value: Binding<String>,
        placeholder: String,
        prefix: String? = nil,
        suffix: String? = nil,
        icon: String,
        color: Color = .blue,
        keyboardType: UIKeyboardType = .decimalPad,
        helpText: String? = nil,
        onPrevious: (() -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        onDone: (() -> Void)? = nil,
        showPreviousButton: Bool = true,
        showNextButton: Bool = true
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.prefix = prefix
        self.suffix = suffix
        self.icon = icon
        self.color = color
        self.keyboardType = keyboardType
        self.helpText = helpText
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onDone = onDone
        self.showPreviousButton = showPreviousButton
        self.showNextButton = showNextButton
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title with icon
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Input field
            HStack(spacing: 12) {
                if let prefix = prefix {
                    Text(prefix)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .frame(minWidth: 20)
                }
                
                if keyboardType == .decimalPad && (onPrevious != nil || onNext != nil || onDone != nil) {
                    KeyboardToolbarTextField(
                        text: $value,
                        placeholder: placeholder,
                        onPrevious: onPrevious,
                        onNext: onNext,
                        onDone: onDone,
                        showPreviousButton: showPreviousButton,
                        showNextButton: showNextButton
                    )
                } else {
                    TextField(placeholder, text: $value)
                        .keyboardType(keyboardType)
                        .font(.title2)
                        .fontWeight(.medium)
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.leading)
                }
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 30, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        value.isEmpty ? Color(.systemGray4) : color.opacity(0.6),
                        lineWidth: value.isEmpty ? 1.5 : 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.easeInOut(duration: 0.2), value: value.isEmpty)
        }
        .id(fieldId)
    }
}

struct CompactInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let prefix: String?
    let suffix: String?
    let color: Color
    let keyboardType: UIKeyboardType
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?
    var showPreviousButton: Bool = true
    var showNextButton: Bool = true
    
    private var fieldId: String {
        "input-\(title.replacingOccurrences(of: " ", with: "-").lowercased())"
    }
    
    init(
        title: String,
        value: Binding<String>,
        placeholder: String,
        prefix: String? = nil,
        suffix: String? = nil,
        color: Color = .blue,
        keyboardType: UIKeyboardType = .decimalPad,
        onPrevious: (() -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        onDone: (() -> Void)? = nil,
        showPreviousButton: Bool = true,
        showNextButton: Bool = true
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.prefix = prefix
        self.suffix = suffix
        self.color = color
        self.keyboardType = keyboardType
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onDone = onDone
        self.showPreviousButton = showPreviousButton
        self.showNextButton = showNextButton
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            HStack(spacing: 8) {
                if let prefix = prefix {
                    Text(prefix)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
                
                if keyboardType == .decimalPad && (onPrevious != nil || onNext != nil || onDone != nil) {
                    KeyboardToolbarTextField(
                        text: $value,
                        placeholder: placeholder,
                        onPrevious: onPrevious,
                        onNext: onNext,
                        onDone: onDone,
                        showPreviousButton: showPreviousButton,
                        showNextButton: showNextButton
                    )
                } else {
                    TextField(placeholder, text: $value)
                        .keyboardType(keyboardType)
                        .font(.headline)
                        .fontWeight(.medium)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(value.isEmpty ? Color(.systemGray5) : color.opacity(0.3), lineWidth: 1)
            )
        }
        .id(fieldId)
    }
}

struct GroupedInputFields<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        color: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .frame(width: 24)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Content
            VStack(spacing: 16) {
                content
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct SegmentedInputField<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [(T, String)]
    let icon: String?
    let color: Color
    
    init(
        title: String,
        selection: Binding<T>,
        options: [(T, String)],
        icon: String? = nil,
        color: Color = .blue
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ToggleInputField: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    init(
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        icon: String,
        color: Color = .blue
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(color)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Helper Components

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Number Formatter Extensions

extension NumberFormatter {
    static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    static func formatDecimal(_ value: Double, precision: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = precision
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    static func formatPercent(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value / 100)) ?? "0%"
    }
}

// MARK: - Legacy Calculator Input Field (Deprecated - Use ModernInputField instead)

struct CalculatorInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let suffix: String?
    let prefix: String?
    
    init(
        title: String,
        value: Binding<String>,
        placeholder: String = "0",
        keyboardType: UIKeyboardType = .decimalPad,
        suffix: String? = nil,
        prefix: String? = nil
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.suffix = suffix
        self.prefix = prefix
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                if let prefix = prefix {
                    Text(prefix)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                TextField(placeholder, text: $value)
                    .keyboardType(keyboardType)
                    .font(.title3)
                    .fontWeight(.medium)
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(value.isEmpty ? Color(.systemGray5) : Color.blue.opacity(0.3), lineWidth: 1)
            )
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
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
        Button(action: {
            // Dismiss keyboard first
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            // Execute the action
            action()
        }) {
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