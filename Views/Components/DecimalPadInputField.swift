import SwiftUI
import UIKit

struct DecimalPadInputField: UIViewRepresentable {
    let title: String
    @Binding var text: String
    let placeholder: String
    let suffix: String?
    let prefix: String?
    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?
    var showPreviousButton: Bool = true
    var showNextButton: Bool = true
    var isCurrency: Bool = false
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create input container
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.systemGray6
        inputContainer.layer.cornerRadius = 12
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create text field
        let textField = UITextField()
        textField.text = text
        textField.placeholder = placeholder
        textField.keyboardType = .decimalPad
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        textField.delegate = context.coordinator
        textField.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        // Create prefix label if needed
        var prefixLabel: UILabel?
        if let prefix = prefix {
            let label = UILabel()
            label.text = prefix
            label.font = UIFont.preferredFont(forTextStyle: .title3)
            label.textColor = .systemBlue
            label.translatesAutoresizingMaskIntoConstraints = false
            prefixLabel = label
            inputContainer.addSubview(label)
        }
        
        // Create suffix label if needed
        var suffixLabel: UILabel?
        if let suffix = suffix {
            let label = UILabel()
            label.text = suffix
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            suffixLabel = label
            inputContainer.addSubview(label)
        }
        
        // Add subviews
        container.addSubview(titleLabel)
        container.addSubview(inputContainer)
        inputContainer.addSubview(textField)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            // Input container
            inputContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            inputContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Setup text field constraints
        var textFieldConstraints: [NSLayoutConstraint] = [
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.topAnchor.constraint(greaterThanOrEqualTo: inputContainer.topAnchor, constant: 12),
            textField.bottomAnchor.constraint(lessThanOrEqualTo: inputContainer.bottomAnchor, constant: -12)
        ]
        
        if let prefixLabel = prefixLabel {
            textFieldConstraints.append(contentsOf: [
                prefixLabel.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
                prefixLabel.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
                textField.leadingAnchor.constraint(equalTo: prefixLabel.trailingAnchor, constant: 8)
            ])
        } else {
            textFieldConstraints.append(textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16))
        }
        
        if let suffixLabel = suffixLabel {
            textFieldConstraints.append(contentsOf: [
                textField.trailingAnchor.constraint(equalTo: suffixLabel.leadingAnchor, constant: -8),
                suffixLabel.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
                suffixLabel.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
            ])
        } else {
            textFieldConstraints.append(textField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16))
        }
        
        NSLayoutConstraint.activate(textFieldConstraints)
        
        // Store references for coordinator
        context.coordinator.textField = textField
        context.coordinator.onPrevious = onPrevious
        context.coordinator.onNext = onNext
        context.coordinator.onDone = onDone
        context.coordinator.isCurrency = isCurrency
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let textField = context.coordinator.textField {
            if textField.text != text {
                textField.text = text
            }
        }
        context.coordinator.onPrevious = onPrevious
        context.coordinator.onNext = onNext
        context.coordinator.onDone = onDone
        context.coordinator.isCurrency = isCurrency
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: DecimalPadInputField
        var textField: UITextField?
        var onPrevious: (() -> Void)?
        var onNext: (() -> Void)?
        var onDone: (() -> Void)?
        var isCurrency: Bool = false
        
        private let currencyFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.groupingSeparator = ","
            formatter.usesGroupingSeparator = true
            return formatter
        }()
        
        init(_ parent: DecimalPadInputField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            if !isCurrency {
                parent.text = textField.text ?? ""
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            if isCurrency {
                // Handle currency formatting
                return handleCurrencyInput(textField: textField, range: range, string: string)
            } else {
                // Handle regular decimal input
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
        }
        
        private func handleCurrencyInput(textField: UITextField, range: NSRange, string: String) -> Bool {
            let currentText = textField.text ?? ""
            
            // Allow deletion
            if string.isEmpty {
                let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
                let cleanText = newText.replacingOccurrences(of: ",", with: "")
                parent.text = cleanText
                
                if !cleanText.isEmpty {
                    if let number = Double(cleanText) {
                        let formattedText = currencyFormatter.string(from: NSNumber(value: number)) ?? cleanText
                        textField.text = formattedText
                    }
                } else {
                    textField.text = ""
                }
                return false
            }
            
            // Only allow numbers and decimal point
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            
            // Get the raw number (without commas)
            let rawCurrentText = currentText.replacingOccurrences(of: ",", with: "")
            let newRawText = (rawCurrentText as NSString).replacingCharacters(in: range, with: string)
            
            // Allow only one decimal point
            let decimalCount = newRawText.components(separatedBy: ".").count - 1
            if decimalCount > 1 {
                return false
            }
            
            // Limit decimal places to 2
            if let decimalIndex = newRawText.firstIndex(of: ".") {
                let decimalPart = String(newRawText[newRawText.index(after: decimalIndex)...])
                if decimalPart.count > 2 {
                    return false
                }
            }
            
            // Update parent with raw text
            parent.text = newRawText
            
            // Format and display with commas
            if !newRawText.isEmpty {
                if let number = Double(newRawText) {
                    let formattedText = currencyFormatter.string(from: NSNumber(value: number)) ?? newRawText
                    textField.text = formattedText
                }
            } else {
                textField.text = ""
            }
            
            return false
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