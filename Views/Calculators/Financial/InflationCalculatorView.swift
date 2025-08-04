import SwiftUI

struct InflationCalculatorView: View {
    @State private var currentAmount = ""
    @State private var inflationRate = "3.0"
    @State private var timeYears = ""
    @State private var calculationType = InflationCalculationType.futureValue
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: InflationField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum InflationField: CaseIterable {
        case currentAmount, inflationRate, timeYears
    }
    
    enum InflationCalculationType: String, CaseIterable {
        case futureValue = "Future Purchasing Power"
        case pastValue = "Past Value in Today's Dollars"
        case requiredAmount = "Amount Needed to Maintain Value"
        
        var description: String {
            switch self {
            case .futureValue: return "What today's money will be worth in the future"
            case .pastValue: return "What past money is worth in today's dollars"
            case .requiredAmount: return "How much you'll need to maintain purchasing power"
            }
        }
    }
    
    var calculatedValue: Double {
        guard let amount = Double(currentAmount),
              let rate = Double(inflationRate),
              let years = Double(timeYears),
              amount > 0, rate >= 0, years > 0 else { return 0 }
        
        let inflationMultiplier = pow(1 + rate/100, years)
        
        switch calculationType {
        case .futureValue:
            return amount / inflationMultiplier // Purchasing power decreases
        case .pastValue:
            return amount * inflationMultiplier // Past money worth more today
        case .requiredAmount:
            return amount * inflationMultiplier // Need more to maintain value
        }
    }
    
    var totalInflation: Double {
        guard let rate = Double(inflationRate),
              let years = Double(timeYears) else { return 0 }
        return (pow(1 + rate/100, years) - 1) * 100
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Inflation Calculator", description: "Calculate purchasing power over time") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Calculation Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calculation Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Calculation Type", selection: $calculationType) {
                            ForEach(InflationCalculationType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Text(calculationType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Input Fields
                    ModernInputField(
                        title: calculationType == .pastValue ? "Past Amount" : "Current Amount",
                        value: $currentAmount,
                        placeholder: "1000",
                        prefix: "$",
                        icon: "dollarsign.circle.fill",
                        color: .green,
                        keyboardType: .decimalPad,
                        helpText: "Enter the amount to analyze",
                        onNext: { focusNextField(.currentAmount) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .currentAmount)
                    .id(InflationField.currentAmount)
                    
                    ModernInputField(
                        title: "Annual Inflation Rate",
                        value: $inflationRate,
                        placeholder: "3.0",
                        suffix: "%",
                        icon: "percent",
                        color: .orange,
                        keyboardType: .decimalPad,
                        helpText: "Expected annual inflation rate",
                        onPrevious: { focusPreviousField(.inflationRate) },
                        onNext: { focusNextField(.inflationRate) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .inflationRate)
                    .id(InflationField.inflationRate)
                    
                    ModernInputField(
                        title: "Time Period",
                        value: $timeYears,
                        placeholder: "10",
                        suffix: "years",
                        icon: "calendar",
                        color: .blue,
                        keyboardType: .numberPad,
                        helpText: "Number of years to calculate",
                        onPrevious: { focusPreviousField(.timeYears) },
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .timeYears)
                    .id(InflationField.timeYears)
                
                // Quick inflation rate buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Inflation Rates")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(["2.0", "3.0", "4.0", "6.0", "8.0"], id: \.self) { rate in
                            Button(rate + "%") {
                                inflationRate = rate
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            .foregroundColor(inflationRate == rate ? .white : .blue)
                            .background(inflationRate == rate ? Color.blue : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Inflation Impact") {
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
                if showResults && calculatedValue > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Inflation Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        switch calculationType {
                        case .futureValue:
                            CalculatorResultCard(
                                title: "Future Purchasing Power",
                                value: NumberFormatter.formatCurrency(calculatedValue),
                                subtitle: "What $\(currentAmount) buys in \(timeYears) years",
                                color: .orange
                            )
                            
                        case .pastValue:
                            CalculatorResultCard(
                                title: "Value in Today's Dollars",
                                value: NumberFormatter.formatCurrency(calculatedValue),
                                subtitle: "$\(currentAmount) from \(timeYears) years ago",
                                color: .green
                            )
                            
                        case .requiredAmount:
                            CalculatorResultCard(
                                title: "Amount Needed",
                                value: NumberFormatter.formatCurrency(calculatedValue),
                                subtitle: "To maintain $\(currentAmount) purchasing power",
                                color: .blue
                            )
                        }
                        
                        // Inflation Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Inflation Impact")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Original amount",
                                    value: NumberFormatter.formatCurrency(Double(currentAmount) ?? 0)
                                )
                                InfoRow(
                                    label: "Inflation rate",
                                    value: NumberFormatter.formatPercent(Double(inflationRate) ?? 0)
                                )
                                InfoRow(
                                    label: "Time period",
                                    value: "\(timeYears) years"
                                )
                                InfoRow(
                                    label: "Total inflation",
                                    value: NumberFormatter.formatPercent(totalInflation)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Real-world Examples
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Real-World Impact")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let examples = getInflationExamples()
                            VStack(spacing: 8) {
                                ForEach(examples, id: \.item) { example in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(example.item)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(example.impact)
                                                .font(.subheadline)
                                        }
                                        Text(example.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Protection Strategies
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "shield.fill")
                                    .foregroundColor(.blue)
                                Text("Inflation Protection Strategies")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Invest in stocks and real estate for long-term growth")
                                Text("• Consider Treasury Inflation-Protected Securities (TIPS)")
                                Text("• Maintain some exposure to commodities")
                                Text("• Avoid keeping large cash reserves long-term")
                                Text("• Focus on assets that historically outpace inflation")
                                Text("• Consider fixed-rate debt (inflation helps borrowers)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            InflationInfoSheet()
        }
    }
    
    private func getInflationExamples() -> [(item: String, impact: String, description: String)] {
        guard let rate = Double(inflationRate),
              let years = Double(timeYears) else { return [] }
        
        let multiplier = pow(1 + rate/100, years)
        
        return [
            ("Cup of Coffee", "$\(String(format: "%.2f", 5.00 * multiplier))", "$5.00 coffee today"),
            ("Gallon of Gas", "$\(String(format: "%.2f", 3.50 * multiplier))", "$3.50 gas today"),
            ("Movie Ticket", "$\(String(format: "%.2f", 12.00 * multiplier))", "$12.00 ticket today"),
            ("Grocery Bill", "$\(String(format: "%.0f", 100.00 * multiplier))", "$100 groceries today")
        ]
    }
    
    private func focusNextField(_ currentField: InflationField) {
        let allFields = InflationField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: InflationField) {
        let allFields = InflationField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        currentAmount = "10000"
        inflationRate = "3.0"
        timeYears = "10"
        calculationType = .futureValue
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        currentAmount = ""
        inflationRate = "3.0"
        timeYears = ""
        calculationType = .futureValue
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Inflation Calculator Results:
        Amount: $\(currentAmount)
        Inflation Rate: \(inflationRate)%
        Time Period: \(timeYears) years
        \(calculationType.rawValue): \(NumberFormatter.formatCurrency(calculatedValue))
        Total Inflation: \(NumberFormatter.formatPercent(totalInflation))
        """
        
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

struct InflationInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Inflation Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you understand how inflation affects the purchasing power of money over time."
                        )
                        
                        InfoSection(
                            title: "Calculation Types",
                            content: """
                            • Future Purchasing Power: What today's money will buy in the future
                            • Past Value: What old money is worth in today's dollars
                            • Amount Needed: How much you'll need to maintain purchasing power
                            """
                        )
                        
                        InfoSection(
                            title: "Understanding Inflation",
                            content: """
                            • Inflation reduces purchasing power over time
                            • Historical US average: ~3% annually
                            • Compound effect becomes significant over long periods
                            • Consider inflation when planning long-term finances
                            """
                        )
                        
                        InfoSection(
                            title: "Protection Strategies",
                            content: """
                            • Invest in assets that historically outpace inflation
                            • Consider Treasury Inflation-Protected Securities (TIPS)
                            • Maintain exposure to stocks and real estate
                            • Avoid keeping large cash reserves long-term
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Inflation Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}