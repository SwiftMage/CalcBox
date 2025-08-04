import SwiftUI

struct RetirementPlanningView: View {
    @State private var currentAge = ""
    @State private var retirementAge = "65"
    @State private var currentSavings = ""
    @State private var monthlyContribution = ""
    @State private var employerMatch = ""
    @State private var expectedReturn = "7"
    @State private var desiredMonthlyIncome = ""
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: RetirementField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum RetirementField: CaseIterable {
        case currentAge, retirementAge, currentSavings, monthlyContribution, employerMatch, expectedReturn, desiredMonthlyIncome
    }
    
    var yearsUntilRetirement: Double {
        guard let current = Double(currentAge),
              let retirement = Double(retirementAge) else { return 0 }
        return max(0, retirement - current)
    }
    
    var totalAtRetirement: Double {
        guard let savings = Double(currentSavings),
              let monthly = Double(monthlyContribution),
              let match = Double(employerMatch),
              let rate = Double(expectedReturn) else { return 0 }
        
        let years = yearsUntilRetirement
        let monthlyRate = rate / 100 / 12
        let months = years * 12
        let totalMonthly = monthly + match
        
        // Future value of current savings
        let currentValue = savings * pow(1 + rate/100, years)
        
        // Future value of monthly contributions
        let monthlyValue = totalMonthly * ((pow(1 + monthlyRate, months) - 1) / monthlyRate)
        
        return currentValue + monthlyValue
    }
    
    var monthlyIncomeAtRetirement: Double {
        // Using 4% withdrawal rule
        return totalAtRetirement * 0.04 / 12
    }
    
    var shortfall: Double {
        guard let desired = Double(desiredMonthlyIncome) else { return 0 }
        return max(0, desired - monthlyIncomeAtRetirement)
    }
    
    var additionalSavingsNeeded: Double {
        guard shortfall > 0 else { return 0 }
        // Amount needed to generate shortfall income using 4% rule
        return shortfall * 12 / 0.04
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Retirement Planning", description: "401k and IRA calculations") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Personal Information
                    GroupedInputFields(
                        title: "Personal Information",
                        icon: "person.circle.fill",
                        color: .blue
                    ) {
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Current Age",
                                value: $currentAge,
                                placeholder: "30",
                                suffix: "years",
                                color: .green,
                                keyboardType: .numberPad,
                                onNext: { focusNextField(.currentAge) },
                                onDone: { focusedField = nil },
                                showPreviousButton: false
                            )
                            .focused($focusedField, equals: .currentAge)
                            .id(RetirementField.currentAge)
                            
                            CompactInputField(
                                title: "Retirement Age",
                                value: $retirementAge,
                                placeholder: "65",
                                suffix: "years",
                                color: .orange,
                                keyboardType: .numberPad,
                                onPrevious: { focusPreviousField(.retirementAge) },
                                onNext: { focusNextField(.retirementAge) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .retirementAge)
                            .id(RetirementField.retirementAge)
                        }
                    }
                    
                    // Current Savings
                    GroupedInputFields(
                        title: "Current Savings",
                        icon: "banknote.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Current Retirement Savings",
                            value: $currentSavings,
                            placeholder: "50000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Total value of 401(k), IRA, and other retirement accounts",
                            onPrevious: { focusPreviousField(.currentSavings) },
                            onNext: { focusNextField(.currentSavings) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .currentSavings)
                        .id(RetirementField.currentSavings)
                    }
                    
                    // Monthly Contributions
                    GroupedInputFields(
                        title: "Monthly Contributions",
                        icon: "arrow.up.circle.fill",
                        color: .blue
                    ) {
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Your Contribution",
                                value: $monthlyContribution,
                                placeholder: "500",
                                prefix: "$",
                                color: .blue,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.monthlyContribution) },
                                onNext: { focusNextField(.monthlyContribution) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .monthlyContribution)
                            .id(RetirementField.monthlyContribution)
                            
                            CompactInputField(
                                title: "Employer Match",
                                value: $employerMatch,
                                placeholder: "250",
                                prefix: "$",
                                color: .purple,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.employerMatch) },
                                onNext: { focusNextField(.employerMatch) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .employerMatch)
                            .id(RetirementField.employerMatch)
                        }
                    }
                    
                    // Investment Assumptions
                    GroupedInputFields(
                        title: "Investment Assumptions",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    ) {
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Expected Annual Return",
                                value: $expectedReturn,
                                placeholder: "7",
                                suffix: "%",
                                color: .orange,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.expectedReturn) },
                                onNext: { focusNextField(.expectedReturn) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .expectedReturn)
                            .id(RetirementField.expectedReturn)
                            
                            CompactInputField(
                                title: "Desired Monthly Income",
                                value: $desiredMonthlyIncome,
                                placeholder: "4000",
                                prefix: "$",
                                color: .red,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.desiredMonthlyIncome) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .desiredMonthlyIncome)
                            .id(RetirementField.desiredMonthlyIncome)
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Plan Retirement") {
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
                    if showResults && yearsUntilRetirement > 0 {
                        VStack(spacing: 16) {
                            Divider()
                                .id("results")
                        
                        Text("Retirement Projection")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Key Results
                        VStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "Projected Retirement Savings",
                                value: NumberFormatter.formatCurrency(totalAtRetirement),
                                subtitle: "At age \(retirementAge)",
                                color: .green
                            )
                            
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Monthly Income",
                                    value: NumberFormatter.formatCurrency(monthlyIncomeAtRetirement),
                                    subtitle: "4% withdrawal rule",
                                    color: .blue
                                )
                                
                                if shortfall > 0 {
                                    CalculatorResultCard(
                                        title: "Monthly Shortfall",
                                        value: NumberFormatter.formatCurrency(shortfall),
                                        color: .red
                                    )
                                } else {
                                    CalculatorResultCard(
                                        title: "Goal Status",
                                        value: "On Track!",
                                        color: .green
                                    )
                                }
                            }
                        }
                        
                        // Contribution Analysis
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contribution Analysis")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let totalMonthly = (Double(monthlyContribution) ?? 0) + (Double(employerMatch) ?? 0)
                            let totalContributions = totalMonthly * yearsUntilRetirement * 12
                            let growth = totalAtRetirement - (Double(currentSavings) ?? 0) - totalContributions
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Years until retirement",
                                    value: "\(Int(yearsUntilRetirement)) years"
                                )
                                InfoRow(
                                    label: "Your monthly contribution",
                                    value: NumberFormatter.formatCurrency(Double(monthlyContribution) ?? 0)
                                )
                                InfoRow(
                                    label: "Employer match",
                                    value: NumberFormatter.formatCurrency(Double(employerMatch) ?? 0)
                                )
                                InfoRow(
                                    label: "Total monthly savings",
                                    value: NumberFormatter.formatCurrency(totalMonthly)
                                )
                                InfoRow(
                                    label: "Total contributions",
                                    value: NumberFormatter.formatCurrency(totalContributions)
                                )
                                InfoRow(
                                    label: "Investment growth",
                                    value: NumberFormatter.formatCurrency(growth)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Goal Assessment
                        if !desiredMonthlyIncome.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Goal Assessment")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if shortfall > 0 {
                                    VStack(spacing: 8) {
                                        InfoRow(
                                            label: "Desired monthly income",
                                            value: NumberFormatter.formatCurrency(Double(desiredMonthlyIncome) ?? 0)
                                        )
                                        InfoRow(
                                            label: "Projected monthly income",
                                            value: NumberFormatter.formatCurrency(monthlyIncomeAtRetirement)
                                        )
                                        InfoRow(
                                            label: "Monthly shortfall",
                                            value: NumberFormatter.formatCurrency(shortfall)
                                        )
                                        InfoRow(
                                            label: "Additional savings needed",
                                            value: NumberFormatter.formatCurrency(additionalSavingsNeeded)
                                        )
                                        
                                        let additionalMonthly = additionalSavingsNeeded / (yearsUntilRetirement * 12)
                                        InfoRow(
                                            label: "Extra monthly contribution needed",
                                            value: NumberFormatter.formatCurrency(additionalMonthly)
                                        )
                                    }
                                } else {
                                    Text("✓ You're on track to meet your retirement income goal!")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(shortfall > 0 ? Color(.systemRed).opacity(0.1) : Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Retirement Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Retirement Planning Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Start early - compound interest is powerful")
                                Text("• Take full advantage of employer matching")
                                Text("• Consider increasing contributions with salary raises")
                                Text("• Diversify investments across asset classes")
                                Text("• Review and adjust plan annually")
                                Text("• Consider Roth vs Traditional 401(k) benefits")
                                Text("• Don't forget about Social Security benefits")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemYellow).opacity(0.1))
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
            RetirementInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: RetirementField) {
        let allFields = RetirementField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
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
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        currentAge = "30"
        retirementAge = "65"
        currentSavings = "50000"
        monthlyContribution = "500"
        employerMatch = "250"
        expectedReturn = "7"
        desiredMonthlyIncome = "4000"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        currentAge = ""
        retirementAge = "65"
        currentSavings = ""
        monthlyContribution = ""
        employerMatch = ""
        expectedReturn = "7"
        desiredMonthlyIncome = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Retirement Planning Results:
        Current Age: \(currentAge)
        Retirement Age: \(retirementAge)
        Years Until Retirement: \(Int(yearsUntilRetirement))
        Current Savings: $\(currentSavings)
        Monthly Contribution: $\(monthlyContribution)
        Employer Match: $\(employerMatch)
        Projected Retirement Savings: \(NumberFormatter.formatCurrency(totalAtRetirement))
        Projected Monthly Income: \(NumberFormatter.formatCurrency(monthlyIncomeAtRetirement))
        Goal Status: \(shortfall > 0 ? "Additional savings needed" : "On track!")
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

struct RetirementInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Retirement Planning Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator projects your retirement savings growth and determines if you're on track to meet your retirement income goals using the 4% withdrawal rule."
                        )
                        
                        InfoSection(
                            title: "Key Concepts",
                            content: """
                            • 4% Rule: Withdraw 4% annually from retirement savings
                            • Compound Growth: Your money grows exponentially over time
                            • Employer Match: Free money - always maximize this benefit
                            • Time Horizon: Earlier start = more compound growth
                            """
                        )
                        
                        InfoSection(
                            title: "Planning Tips",
                            content: """
                            • Start saving as early as possible
                            • Increase contributions with salary raises
                            • Take full advantage of employer matching
                            • Consider both traditional and Roth options
                            • Review and adjust annually
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