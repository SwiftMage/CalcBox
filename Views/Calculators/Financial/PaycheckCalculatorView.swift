import SwiftUI

struct PaycheckCalculatorView: View {
    @State private var salary = ""
    @State private var payFrequency = PayFrequency.biweekly
    @State private var federalWithholding = "22"
    @State private var stateWithholding = "5"
    @State private var socialSecurity = "6.2"
    @State private var medicare = "1.45"
    @State private var healthInsurance = ""
    @State private var retirement401k = ""
    @State private var otherDeductions = ""
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: PaycheckField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum PayFrequency: String, CaseIterable {
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case semimonthly = "Semi-monthly"
        case monthly = "Monthly"
        
        var periodsPerYear: Double {
            switch self {
            case .weekly: return 52
            case .biweekly: return 26
            case .semimonthly: return 24
            case .monthly: return 12
            }
        }
    }
    
    enum PaycheckField: CaseIterable {
        case salary, federalWithholding, stateWithholding, socialSecurity, medicare, healthInsurance, retirement401k, otherDeductions
    }
    
    var annualSalary: Double {
        Double(salary) ?? 0
    }
    
    var grossPayPerPeriod: Double {
        guard annualSalary > 0 else { return 0 }
        return annualSalary / payFrequency.periodsPerYear
    }
    
    var federalTax: Double {
        grossPayPerPeriod * ((Double(federalWithholding) ?? 0) / 100)
    }
    
    var stateTax: Double {
        grossPayPerPeriod * ((Double(stateWithholding) ?? 0) / 100)
    }
    
    var socialSecurityTax: Double {
        grossPayPerPeriod * ((Double(socialSecurity) ?? 0) / 100)
    }
    
    var medicareTax: Double {
        grossPayPerPeriod * ((Double(medicare) ?? 0) / 100)
    }
    
    var healthInsuranceDeduction: Double {
        Double(healthInsurance) ?? 0
    }
    
    var retirement401kDeduction: Double {
        let percentage = (Double(retirement401k) ?? 0) / 100
        return grossPayPerPeriod * percentage
    }
    
    var otherDeductionsAmount: Double {
        Double(otherDeductions) ?? 0
    }
    
    var totalTaxes: Double {
        federalTax + stateTax + socialSecurityTax + medicareTax
    }
    
    var totalDeductions: Double {
        healthInsuranceDeduction + retirement401kDeduction + otherDeductionsAmount
    }
    
    var netPayPerPeriod: Double {
        grossPayPerPeriod - totalTaxes - totalDeductions
    }
    
    var annualNetPay: Double {
        netPayPerPeriod * payFrequency.periodsPerYear
    }
    
    var effectiveTaxRate: Double {
        guard grossPayPerPeriod > 0 else { return 0 }
        return (totalTaxes / grossPayPerPeriod) * 100
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Paycheck Calculator", description: "Calculate take-home pay after taxes") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Basic Income Info
                    GroupedInputFields(
                        title: "Income Details",
                        icon: "banknote.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Annual Salary",
                            value: $salary,
                            placeholder: "75000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Your gross annual salary before taxes",
                            onNext: { focusNextField(.salary) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .salary)
                        .id(PaycheckField.salary)
                        
                        SegmentedPicker(
                            title: "Pay Frequency",
                            selection: $payFrequency,
                            options: PayFrequency.allCases.map { ($0, $0.rawValue) }
                        )
                    }
                
                // Tax Withholdings
                GroupedInputFields(
                    title: "Tax Withholdings",
                    icon: "percent",
                    color: .red
                ) {
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Federal Tax",
                            value: $federalWithholding,
                            placeholder: "22",
                            suffix: "%",
                            color: .red,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.federalWithholding) },
                            onNext: { focusNextField(.federalWithholding) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .federalWithholding)
                        .id(PaycheckField.federalWithholding)
                        
                        CompactInputField(
                            title: "State Tax",
                            value: $stateWithholding,
                            placeholder: "5",
                            suffix: "%",
                            color: .orange,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.stateWithholding) },
                            onNext: { focusNextField(.stateWithholding) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .stateWithholding)
                        .id(PaycheckField.stateWithholding)
                    }
                    
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Social Security",
                            value: $socialSecurity,
                            placeholder: "6.2",
                            suffix: "%",
                            color: .blue,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.socialSecurity) },
                            onNext: { focusNextField(.socialSecurity) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .socialSecurity)
                        .id(PaycheckField.socialSecurity)
                        
                        CompactInputField(
                            title: "Medicare",
                            value: $medicare,
                            placeholder: "1.45",
                            suffix: "%",
                            color: .purple,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.medicare) },
                            onNext: { focusNextField(.medicare) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .medicare)
                        .id(PaycheckField.medicare)
                    }
                }
                
                // Pre-tax Deductions
                GroupedInputFields(
                    title: "Deductions (Per Pay Period)",
                    icon: "minus.circle.fill",
                    color: .blue
                ) {
                    ModernInputField(
                        title: "Health Insurance",
                        value: $healthInsurance,
                        placeholder: "150",
                        prefix: "$",
                        icon: "cross.circle.fill",
                        color: .green,
                        keyboardType: .decimalPad,
                        helpText: "Monthly premium divided by pay periods",
                        onPrevious: { focusPreviousField(.healthInsurance) },
                        onNext: { focusNextField(.healthInsurance) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .healthInsurance)
                    .id(PaycheckField.healthInsurance)
                    
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "401(k) Contribution",
                            value: $retirement401k,
                            placeholder: "10",
                            suffix: "%",
                            color: .purple,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.retirement401k) },
                            onNext: { focusNextField(.retirement401k) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .retirement401k)
                        .id(PaycheckField.retirement401k)
                        
                        CompactInputField(
                            title: "Other Deductions",
                            value: $otherDeductions,
                            placeholder: "50",
                            prefix: "$",
                            color: .orange,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.otherDeductions) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .otherDeductions)
                        .id(PaycheckField.otherDeductions)
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Paycheck") {
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
                if showResults && netPayPerPeriod > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Paycheck Breakdown")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Results
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Gross Pay",
                                value: NumberFormatter.formatCurrency(grossPayPerPeriod),
                                subtitle: "Per \(payFrequency.rawValue.lowercased())",
                                color: .blue
                            )
                            
                            CalculatorResultCard(
                                title: "Net Pay",
                                value: NumberFormatter.formatCurrency(netPayPerPeriod),
                                subtitle: "Take-home pay",
                                color: .green
                            )
                        }
                        
                        // Annual Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Annual Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Gross Annual Salary",
                                    value: NumberFormatter.formatCurrency(annualSalary)
                                )
                                InfoRow(
                                    label: "Net Annual Pay",
                                    value: NumberFormatter.formatCurrency(annualNetPay)
                                )
                                InfoRow(
                                    label: "Total Annual Taxes",
                                    value: NumberFormatter.formatCurrency(totalTaxes * payFrequency.periodsPerYear)
                                )
                                InfoRow(
                                    label: "Effective Tax Rate",
                                    value: NumberFormatter.formatPercent(effectiveTaxRate)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Tax Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tax & Deduction Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                if federalTax > 0 {
                                    InfoRow(
                                        label: "Federal Income Tax",
                                        value: NumberFormatter.formatCurrency(federalTax)
                                    )
                                }
                                if stateTax > 0 {
                                    InfoRow(
                                        label: "State Income Tax",
                                        value: NumberFormatter.formatCurrency(stateTax)
                                    )
                                }
                                if socialSecurityTax > 0 {
                                    InfoRow(
                                        label: "Social Security",
                                        value: NumberFormatter.formatCurrency(socialSecurityTax)
                                    )
                                }
                                if medicareTax > 0 {
                                    InfoRow(
                                        label: "Medicare",
                                        value: NumberFormatter.formatCurrency(medicareTax)
                                    )
                                }
                                if healthInsuranceDeduction > 0 {
                                    InfoRow(
                                        label: "Health Insurance",
                                        value: NumberFormatter.formatCurrency(healthInsuranceDeduction)
                                    )
                                }
                                if retirement401kDeduction > 0 {
                                    InfoRow(
                                        label: "401(k) Contribution",
                                        value: NumberFormatter.formatCurrency(retirement401kDeduction)
                                    )
                                }
                                if otherDeductionsAmount > 0 {
                                    InfoRow(
                                        label: "Other Deductions",
                                        value: NumberFormatter.formatCurrency(otherDeductionsAmount)
                                    )
                                }
                                
                                Divider()
                                InfoRow(
                                    label: "Total Taxes & Deductions",
                                    value: NumberFormatter.formatCurrency(totalTaxes + totalDeductions)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Budget Guidelines
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Budget Guidelines (Monthly)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let monthlyNet = netPayPerPeriod * payFrequency.periodsPerYear / 12
                            
                            VStack(spacing: 6) {
                                InfoRow(
                                    label: "Housing (30%)",
                                    value: NumberFormatter.formatCurrency(monthlyNet * 0.30)
                                )
                                InfoRow(
                                    label: "Transportation (15%)",
                                    value: NumberFormatter.formatCurrency(monthlyNet * 0.15)
                                )
                                InfoRow(
                                    label: "Food (12%)",
                                    value: NumberFormatter.formatCurrency(monthlyNet * 0.12)
                                )
                                InfoRow(
                                    label: "Savings (20%)",
                                    value: NumberFormatter.formatCurrency(monthlyNet * 0.20)
                                )
                                InfoRow(
                                    label: "Other Expenses (23%)",
                                    value: NumberFormatter.formatCurrency(monthlyNet * 0.23)
                                )
                            }
                            
                            Text("Based on common budgeting guidelines")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            PaycheckInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: PaycheckField) {
        let allFields = PaycheckField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: PaycheckField) {
        let allFields = PaycheckField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        salary = "75000"
        payFrequency = .biweekly
        federalWithholding = "22"
        stateWithholding = "5"
        socialSecurity = "6.2"
        medicare = "1.45"
        healthInsurance = "150"
        retirement401k = "6"
        otherDeductions = "50"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        salary = ""
        payFrequency = .biweekly
        federalWithholding = "22"
        stateWithholding = "5"
        socialSecurity = "6.2"
        medicare = "1.45"
        healthInsurance = ""
        retirement401k = ""
        otherDeductions = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Paycheck Calculation Results:
        Annual Salary: $\(salary)
        Pay Frequency: \(payFrequency.rawValue)
        Gross Pay: \(NumberFormatter.formatCurrency(grossPayPerPeriod))
        Net Pay: \(NumberFormatter.formatCurrency(netPayPerPeriod))
        Effective Tax Rate: \(NumberFormatter.formatPercent(effectiveTaxRate))
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

struct PaycheckInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Paycheck Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines your take-home pay after federal taxes, state taxes, Social Security, Medicare, and pre-tax deductions."
                        )
                        
                        InfoSection(
                            title: "Tax Withholdings",
                            content: """
                            • Federal Tax: Based on your tax bracket
                            • State Tax: Varies by state (0-13%)
                            • Social Security: 6.2% up to annual wage base
                            • Medicare: 1.45% on all earnings
                            """
                        )
                        
                        InfoSection(
                            title: "Common Deductions",
                            content: """
                            • Health Insurance: Pre-tax premium
                            • 401(k): Pre-tax retirement savings
                            • Other: HSA, FSA, parking, etc.
                            """
                        )
                        
                        InfoSection(
                            title: "Budget Guidelines",
                            content: """
                            • Housing: 30% of net income
                            • Transportation: 15% of net income
                            • Savings: 20% of net income
                            • Food: 12% of net income
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Paycheck Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}