import SwiftUI

struct PercentageCalculatorView: View {
    @State private var calculationType = CalculationType.percentOf
    @State private var value1 = ""
    @State private var value2 = ""
    @State private var originalValue = ""
    @State private var newValue = ""
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: PercentageField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum PercentageField: CaseIterable {
        case value1, value2, originalValue, newValue
    }
    
    enum CalculationType: String, CaseIterable {
        case percentOf = "What is X% of Y?"
        case whatPercent = "X is what % of Y?"
        case percentageChange = "Percentage Change"
        case increaseDecrease = "Increase/Decrease by %"
        
        var description: String {
            switch self {
            case .percentOf: return "Calculate a percentage of a number"
            case .whatPercent: return "Find what percentage one number is of another"
            case .percentageChange: return "Calculate percentage change between two values"
            case .increaseDecrease: return "Increase or decrease a number by a percentage"
            }
        }
    }
    
    var calculationResult: Double {
        switch calculationType {
        case .percentOf:
            guard let percent = Double(value1),
                  let number = Double(value2) else { return 0 }
            return (percent / 100) * number
            
        case .whatPercent:
            guard let numerator = Double(value1),
                  let denominator = Double(value2),
                  denominator != 0 else { return 0 }
            return (numerator / denominator) * 100
            
        case .percentageChange:
            guard let original = Double(originalValue),
                  let new = Double(newValue),
                  original != 0 else { return 0 }
            return ((new - original) / original) * 100
            
        case .increaseDecrease:
            guard let base = Double(value1),
                  let percent = Double(value2) else { return 0 }
            return base * (1 + percent / 100)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Percentage Calculator", description: "Calculate percentages and changes") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Calculation Type Selection
                    GroupedInputFields(
                        title: "Calculation Type",
                        icon: "percent",
                        color: .blue
                    ) {
                        SegmentedPicker(
                            title: "Select Calculation",
                            selection: $calculationType,
                            options: CalculationType.allCases.map { ($0, $0.rawValue) }
                        )
                        
                        Text(calculationType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Input Fields based on calculation type
                    GroupedInputFields(
                        title: "Input Values",
                        icon: "textbox",
                        color: .green
                    ) {
                        switch calculationType {
                        case .percentOf:
                            ModernInputField(
                                title: "Percentage",
                                value: $value1,
                                placeholder: "20",
                                suffix: "%",
                                icon: "percent",
                                color: .blue,
                                keyboardType: .decimalPad,
                                helpText: "The percentage you want to calculate",
                                onNext: { focusNextField(.value1) },
                                onDone: { focusedField = nil },
                                showPreviousButton: false
                            )
                            .focused($focusedField, equals: .value1)
                            .id(PercentageField.value1)
                            
                            ModernInputField(
                                title: "Of Number",
                                value: $value2,
                                placeholder: "100",
                                icon: "number",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "The number to calculate the percentage of",
                                onPrevious: { focusPreviousField(.value2) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .value2)
                            .id(PercentageField.value2)
                            
                        case .whatPercent:
                            ModernInputField(
                                title: "First Number",
                                value: $value1,
                                placeholder: "25",
                                icon: "number",
                                color: .blue,
                                keyboardType: .decimalPad,
                                helpText: "The number you want to find the percentage for",
                                onNext: { focusNextField(.value1) },
                                onDone: { focusedField = nil },
                                showPreviousButton: false
                            )
                            .focused($focusedField, equals: .value1)
                            .id(PercentageField.value1)
                            
                            ModernInputField(
                                title: "Is What % of",
                                value: $value2,
                                placeholder: "100",
                                icon: "number",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "The reference number (total or whole)",
                                onPrevious: { focusPreviousField(.value2) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .value2)
                            .id(PercentageField.value2)
                            
                        case .percentageChange:
                            ModernInputField(
                                title: "Original Value",
                                value: $originalValue,
                                placeholder: "100",
                                icon: "arrow.left",
                                color: .orange,
                                keyboardType: .decimalPad,
                                helpText: "The starting value",
                                onNext: { focusNextField(.originalValue) },
                                onDone: { focusedField = nil },
                                showPreviousButton: false
                            )
                            .focused($focusedField, equals: .originalValue)
                            .id(PercentageField.originalValue)
                            
                            ModernInputField(
                                title: "New Value",
                                value: $newValue,
                                placeholder: "120",
                                icon: "arrow.right",
                                color: .purple,
                                keyboardType: .decimalPad,
                                helpText: "The ending value",
                                onPrevious: { focusPreviousField(.newValue) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .newValue)
                            .id(PercentageField.newValue)
                            
                        case .increaseDecrease:
                            ModernInputField(
                                title: "Base Number",
                                value: $value1,
                                placeholder: "100",
                                icon: "number",
                                color: .blue,
                                keyboardType: .decimalPad,
                                helpText: "The starting number to increase or decrease",
                                onNext: { focusNextField(.value1) },
                                onDone: { focusedField = nil },
                                showPreviousButton: false
                            )
                            .focused($focusedField, equals: .value1)
                            .id(PercentageField.value1)
                            
                            ModernInputField(
                                title: "Percentage Change",
                                value: $value2,
                                placeholder: "20",
                                suffix: "%",
                                icon: "percent",
                                color: .purple,
                                keyboardType: .decimalPad,
                                helpText: "Positive % to increase, negative % to decrease",
                                onPrevious: { focusPreviousField(.value2) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .value2)
                            .id(PercentageField.value2)
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate") {
                        withAnimation {
                            showResults = true
                        }
                        // Scroll to results after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("results", anchor: .top)
                            }
                        }
                    }
                
                // Results
                if showResults {
                    VStack(spacing: 20) {
                        Divider()
                            .id("results")
                        
                        Text("Calculation Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        switch calculationType {
                        case .percentOf:
                            CalculatorResultCard(
                                title: "\(value1)% of \(value2) is",
                                value: NumberFormatter.formatDecimal(calculationResult),
                                color: .blue
                            )
                            
                            // Additional context
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Percentage",
                                    value: "\(value1)%"
                                )
                                InfoRow(
                                    label: "Base Number",
                                    value: NumberFormatter.formatDecimal(Double(value2) ?? 0)
                                )
                                InfoRow(
                                    label: "Result",
                                    value: NumberFormatter.formatDecimal(calculationResult)
                                )
                            }
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        case .whatPercent:
                            CalculatorResultCard(
                                title: "\(value1) is",
                                value: NumberFormatter.formatPercent(calculationResult),
                                subtitle: "of \(value2)",
                                color: .green
                            )
                            
                            // Additional context
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Part",
                                    value: NumberFormatter.formatDecimal(Double(value1) ?? 0)
                                )
                                InfoRow(
                                    label: "Whole",
                                    value: NumberFormatter.formatDecimal(Double(value2) ?? 0)
                                )
                                InfoRow(
                                    label: "Percentage",
                                    value: NumberFormatter.formatPercent(calculationResult)
                                )
                            }
                            .padding()
                            .background(Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        case .percentageChange:
                            let isIncrease = calculationResult >= 0
                            CalculatorResultCard(
                                title: isIncrease ? "Percentage Increase" : "Percentage Decrease",
                                value: NumberFormatter.formatPercent(abs(calculationResult)),
                                subtitle: "From \(originalValue) to \(newValue)",
                                color: isIncrease ? .green : .red
                            )
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Original Value",
                                    value: NumberFormatter.formatDecimal(Double(originalValue) ?? 0)
                                )
                                InfoRow(
                                    label: "New Value",
                                    value: NumberFormatter.formatDecimal(Double(newValue) ?? 0)
                                )
                                InfoRow(
                                    label: "Absolute Change",
                                    value: NumberFormatter.formatDecimal(abs((Double(newValue) ?? 0) - (Double(originalValue) ?? 0)))
                                )
                                InfoRow(
                                    label: "Percentage Change",
                                    value: NumberFormatter.formatPercent(calculationResult)
                                )
                            }
                            .padding()
                            .background(Color(isIncrease ? .systemGreen : .systemRed).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        case .increaseDecrease:
                            let isIncrease = (Double(value2) ?? 0) >= 0
                            CalculatorResultCard(
                                title: "Final Result",
                                value: NumberFormatter.formatDecimal(calculationResult),
                                subtitle: "\(value1) \(isIncrease ? "+" : "")\(value2)%",
                                color: .purple
                            )
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Original Amount",
                                    value: NumberFormatter.formatDecimal(Double(value1) ?? 0)
                                )
                                InfoRow(
                                    label: "Percentage Change",
                                    value: "\(isIncrease ? "+" : "")\(value2)%"
                                )
                                InfoRow(
                                    label: "Change Amount",
                                    value: NumberFormatter.formatDecimal(calculationResult - (Double(value1) ?? 0))
                                )
                                InfoRow(
                                    label: "Final Amount",
                                    value: NumberFormatter.formatDecimal(calculationResult)
                                )
                            }
                            .padding()
                            .background(Color(.systemPurple).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                }
                .padding(.bottom, keyboardHeight)
            }
            .onChange(of: focusedField) { field in
                if let field = field {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
        .sheet(isPresented: $showInfo) {
            PercentageInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: PercentageField) {
        let availableFields = getAvailableFields()
        if let currentIndex = availableFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < availableFields.count {
                focusedField = availableFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: PercentageField) {
        let availableFields = getAvailableFields()
        if let currentIndex = availableFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = availableFields[previousIndex]
            }
        }
    }
    
    private func getAvailableFields() -> [PercentageField] {
        switch calculationType {
        case .percentOf, .whatPercent, .increaseDecrease:
            return [.value1, .value2]
        case .percentageChange:
            return [.originalValue, .newValue]
        }
    }
    
    private func fillDemoDataAndCalculate() {
        switch calculationType {
        case .percentOf:
            value1 = "25"
            value2 = "200"
        case .whatPercent:
            value1 = "50"
            value2 = "200"
        case .percentageChange:
            originalValue = "100"
            newValue = "125"
        case .increaseDecrease:
            value1 = "100"
            value2 = "15"
        }
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        value1 = ""
        value2 = ""
        originalValue = ""
        newValue = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText: String
        
        switch calculationType {
        case .percentOf:
            shareText = """
            Percentage Calculation:
            \(value1)% of \(value2) = \(NumberFormatter.formatDecimal(calculationResult))
            """
        case .whatPercent:
            shareText = """
            Percentage Calculation:
            \(value1) is \(NumberFormatter.formatPercent(calculationResult)) of \(value2)
            """
        case .percentageChange:
            let isIncrease = calculationResult >= 0
            shareText = """
            Percentage Change:
            From \(originalValue) to \(newValue)
            \(isIncrease ? "Increase" : "Decrease"): \(NumberFormatter.formatPercent(abs(calculationResult)))
            """
        case .increaseDecrease:
            shareText = """
            Percentage Increase/Decrease:
            \(value1) \((Double(value2) ?? 0) >= 0 ? "+" : "")\(value2)% = \(NumberFormatter.formatDecimal(calculationResult))
            """
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct PercentageInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Percentage Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "Calculation Types",
                            content: """
                            • What is X% of Y?: Find a percentage of a number
                            • X is what % of Y?: Find what percentage one number is of another
                            • Percentage Change: Calculate change between two values
                            • Increase/Decrease by %: Apply percentage change to a number
                            """
                        )
                        
                        InfoSection(
                            title: "Examples",
                            content: """
                            • 25% of 200 = 50
                            • 50 is 25% of 200
                            • From 100 to 125 = 25% increase
                            • 100 + 15% = 115
                            """
                        )
                        
                        InfoSection(
                            title: "Common Uses",
                            content: """
                            • Sales tax and discounts
                            • Tips and gratuities
                            • Grade calculations
                            • Financial growth rates
                            • Population changes
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • To convert a decimal to percentage, multiply by 100
                            • To convert percentage to decimal, divide by 100
                            • Percentage change can be negative (decrease)
                            • Use percentage change for comparing values over time
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Percentage Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}