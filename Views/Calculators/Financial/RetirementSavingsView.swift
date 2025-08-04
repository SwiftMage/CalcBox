import SwiftUI
import Combine

// Temporarily commenting out to fix build issues
/*struct RetirementSavingsView: View {
    @State private var savingsAmount = ""
    @State private var yearlyReturn = ""
    @State private var withdrawalType = WithdrawalType.percentage
    @State private var withdrawalPercentage = ""
    @State private var withdrawalFixed = ""
    
    @State private var showResults = false
    @State private var yearlyBreakdown: [YearlyBreakdown] = []
    @State private var totalYears = 0
    @State private var showInfo = false
    @FocusState private var focusedField: RetirementField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum RetirementField: CaseIterable {
        case savingsAmount, yearlyReturn, withdrawalPercentage, withdrawalFixed
    }
    
    enum WithdrawalType: String, CaseIterable {
        case percentage = "Percentage"
        case fixed = "Fixed Amount"
        
        var displayName: String {
            rawValue
        }
    }
    
    struct YearlyBreakdown: Identifiable {
        let id = UUID()
        let year: Int
        let startingBalance: Double
        let gains: Double
        let withdrawal: Double
        let endingBalance: Double
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(
                title: "Retirement Savings",
                description: "Calculate how long your retirement savings will last"
            ) {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Savings Details
                    GroupedInputFields(
                        title: "Savings Details",
                        icon: "banknote.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Total Savings",
                            value: $savingsAmount,
                            placeholder: "500,000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Your current retirement savings balance",
                            onNext: { focusNextField(.savingsAmount) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .savingsAmount)
                        .id(RetirementField.savingsAmount)
                        
                        CompactInputField(
                            title: "Yearly Return Rate",
                            value: $yearlyReturn,
                            placeholder: "7.0",
                            suffix: "%",
                            color: .blue,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.yearlyReturn) },
                            onNext: { focusNextField(.yearlyReturn) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .yearlyReturn)
                        .id(RetirementField.yearlyReturn)
                    }
                    
                    // Withdrawal Strategy
                    GroupedInputFields(
                        title: "Withdrawal Strategy",
                        icon: "arrow.down.circle.fill",
                        color: .orange
                    ) {
                        SegmentedPicker(
                            title: "Withdrawal Type",
                            selection: $withdrawalType,
                            options: WithdrawalType.allCases.map { ($0, $0.displayName) }
                        )
                        
                        if withdrawalType == .percentage {
                            CompactInputField(
                                title: "Annual Withdrawal Rate",
                                value: $withdrawalPercentage,
                                placeholder: "4.0",
                                suffix: "%",
                                color: .red,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.withdrawalPercentage) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .withdrawalPercentage)
                            .id(RetirementField.withdrawalPercentage)
                        } else {
                            CompactInputField(
                                title: "Annual Withdrawal Amount",
                                value: $withdrawalFixed,
                                placeholder: "40,000",
                                prefix: "$",
                                color: .red,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.withdrawalFixed) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .withdrawalFixed)
                            .id(RetirementField.withdrawalFixed)
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate Duration") {
                        calculateBreakdown()
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
                            
                            Text("Retirement Duration Analysis")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Main Result Card
                            CalculatorResultCard(
                                title: "Your Savings Will Last",
                                value: totalYears > 0 ? "\(totalYears) years" : "Indefinitely",
                                subtitle: totalYears > 0 ? "Based on your withdrawal strategy" : "Your returns exceed withdrawals",
                                color: totalYears > 0 ? (totalYears >= 25 ? .green : .orange) : .green
                            )
                            
                            // Summary Cards
                            HStack(spacing: 12) {
                                if let firstYear = yearlyBreakdown.first {
                                    CalculatorResultCard(
                                        title: "Annual Withdrawal",
                                        value: NumberFormatter.formatCurrency(firstYear.withdrawal),
                                        color: .blue
                                    )
                                    .minimumScaleFactor(0.8)
                                }
                                
                                if let firstYear = yearlyBreakdown.first {
                                    CalculatorResultCard(
                                        title: "Annual Returns",
                                        value: NumberFormatter.formatCurrency(firstYear.gains),
                                        color: .green
                                    )
                                    .minimumScaleFactor(0.8)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            // Yearly Breakdown Table
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Yearly Breakdown")
                                    .font(.headline)
                                
                                ScrollView {
                                    VStack(spacing: 0) {
                                        // Header
                                        HStack {
                                            Text("Year")
                                                .fontWeight(.semibold)
                                                .frame(width: 50, alignment: .leading)
                                            Text("Starting")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            Text("Gains")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            Text("Withdrawal")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            Text("Ending")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        
                                        // Rows
                                        ForEach(yearlyBreakdown) { item in
                                            HStack {
                                                Text("\(item.year)")
                                                    .frame(width: 50, alignment: .leading)
                                                Text(NumberFormatter.formatCurrency(item.startingBalance))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .foregroundColor(.primary)
                                                Text("+\(NumberFormatter.formatCurrency(item.gains))")
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .foregroundColor(.green)
                                                Text("-\(NumberFormatter.formatCurrency(item.withdrawal))")
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .foregroundColor(.red)
                                                Text(NumberFormatter.formatCurrency(item.endingBalance))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .fontWeight(.medium)
                                            }
                                            .font(.footnote)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(item.year % 2 == 0 ? Color.clear : Color(.systemGray6))
                                        }
                                    }
                                }
                                .frame(maxHeight: 400)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
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
            RetirementSavingsInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: RetirementField) {
        let allFields = RetirementField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                // Skip fields that aren't currently visible
                let nextField = allFields[nextIndex]
                if shouldShowField(nextField) {
                    focusedField = nextField
                } else {
                    focusedField = nil
                }
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: RetirementField) {
        let allFields = RetirementField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                let previousField = allFields[previousIndex]
                if shouldShowField(previousField) {
                    focusedField = previousField
                }
            }
        }
    }
    
    private func shouldShowField(_ field: RetirementField) -> Bool {
        switch field {
        case .withdrawalPercentage:
            return withdrawalType == .percentage
        case .withdrawalFixed:
            return withdrawalType == .fixed
        default:
            return true
        }
    }
    
    private func fillDemoDataAndCalculate() {
        savingsAmount = "1000000"
        yearlyReturn = "7"
        withdrawalType = .percentage
        withdrawalPercentage = "4"
        withdrawalFixed = "40000"
        
        calculateBreakdown()
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        savingsAmount = ""
        yearlyReturn = ""
        withdrawalPercentage = ""
        withdrawalFixed = ""
        
        withAnimation {
            showResults = false
        }
        yearlyBreakdown = []
        totalYears = 0
    }
    
    private func shareResults() {
        let withdrawalDescription = withdrawalType == .percentage ? 
            "\(withdrawalPercentage)% annually" : 
            NumberFormatter.formatCurrency(Double(withdrawalFixed) ?? 0) + " annually"
        
        let durationText = totalYears > 0 ? "\(totalYears) years" : "indefinitely"
        
        let shareText = """
        Retirement Savings Analysis:
        Starting Balance: \(NumberFormatter.formatCurrency(Double(savingsAmount) ?? 0))
        Annual Return: \(yearlyReturn)%
        Withdrawal Strategy: \(withdrawalDescription)
        Duration: Your savings will last \(durationText)
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
    
    private func calculateBreakdown() {
        guard let savings = Double(savingsAmount),
              let returnRate = Double(yearlyReturn),
              savings > 0 else {
            yearlyBreakdown = []
            totalYears = 0
            return
        }
        
        var withdrawalAmount: Double = 0
        
        if withdrawalType == .percentage {
            guard let percentage = Double(withdrawalPercentage),
                  percentage > 0 else {
                yearlyBreakdown = []
                totalYears = 0
                return
            }
            withdrawalAmount = savings * (percentage / 100)
        } else {
            guard let fixed = Double(withdrawalFixed),
                  fixed > 0 else {
                yearlyBreakdown = []
                totalYears = 0
                return
            }
            withdrawalAmount = fixed
        }
        
        var breakdown: [YearlyBreakdown] = []
        var currentBalance = savings
        var year = 1
        let maxYears = 100 // Limit to prevent infinite loops
        
        while currentBalance > 0 && year <= maxYears {
            let startingBalance = currentBalance
            let gains = currentBalance * (returnRate / 100)
            
            // For percentage withdrawals, recalculate based on current balance
            let actualWithdrawal = withdrawalType == .percentage ? 
                currentBalance * (Double(withdrawalPercentage) ?? 0) / 100 : 
                withdrawalAmount
            
            // Can't withdraw more than what's available
            let withdrawal = min(actualWithdrawal, currentBalance + gains)
            
            let endingBalance = startingBalance + gains - withdrawal
            
            breakdown.append(YearlyBreakdown(
                year: year,
                startingBalance: startingBalance,
                gains: gains,
                withdrawal: withdrawal,
                endingBalance: max(0, endingBalance)
            ))
            
            if endingBalance <= 0 {
                totalYears = year
                break
            }
            
            currentBalance = endingBalance
            year += 1
        }
        
        // If we hit max years and still have balance, it's indefinite
        if year > maxYears && currentBalance > 0 {
            totalYears = 0 // 0 indicates indefinite
        }
        
        yearlyBreakdown = breakdown
    }
}

struct RetirementSavingsInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Retirement Savings Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines how long your retirement savings will last based on your withdrawal strategy and expected investment returns."
                        )
                        
                        InfoSection(
                            title: "Withdrawal Strategies",
                            content: """
                            • Percentage: Fixed % of current balance each year
                            • Fixed Amount: Same dollar amount withdrawn annually
                            • 4% Rule: Traditional safe withdrawal rate
                            """
                        )
                        
                        InfoSection(
                            title: "Key Considerations",
                            content: """
                            • Market volatility can affect actual results
                            • Inflation reduces purchasing power over time
                            • Consider healthcare and long-term care costs
                            • Tax implications may affect withdrawal amounts
                            """
                        )
                        
                        InfoSection(
                            title: "Tips for Success",
                            content: """
                            • Diversify your investment portfolio
                            • Consider a bond ladder for stability
                            • Review and adjust strategy annually
                            • Plan for sequence of returns risk
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Retirement Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        RetirementSavingsView()
    }
}
*/