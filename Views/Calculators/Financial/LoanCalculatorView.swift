import SwiftUI

struct LoanCalculatorView: View {
    @State private var loanAmount = ""
    @State private var interestRate = ""
    @State private var loanTerm = ""
    @State private var termUnit = TermUnit.years
    @State private var loanType = LoanType.personal
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: LoanField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum LoanField: CaseIterable {
        case loanAmount, interestRate, loanTerm
    }
    
    enum TermUnit: String, CaseIterable {
        case years = "Years"
        case months = "Months"
        
        var monthsMultiplier: Double {
            switch self {
            case .years: return 12
            case .months: return 1
            }
        }
    }
    
    enum LoanType: String, CaseIterable {
        case personal = "Personal Loan"
        case auto = "Auto Loan"
        case home = "Home Loan"
        case student = "Student Loan"
        
        var typicalRate: String {
            switch self {
            case .personal: return "8-15%"
            case .auto: return "3-7%"
            case .home: return "6-8%"
            case .student: return "4-7%"
            }
        }
    }
    
    var totalMonths: Double {
        guard let term = Double(loanTerm) else { return 0 }
        return term * termUnit.monthsMultiplier
    }
    
    var monthlyPayment: Double {
        guard let principal = Double(loanAmount),
              let rate = Double(interestRate),
              principal > 0, rate > 0, totalMonths > 0 else { return 0 }
        
        let monthlyRate = rate / 100 / 12
        
        if monthlyRate == 0 {
            return principal / totalMonths
        }
        
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, totalMonths)) / (pow(1 + monthlyRate, totalMonths) - 1)
        return payment
    }
    
    var totalPayment: Double {
        monthlyPayment * totalMonths
    }
    
    var totalInterest: Double {
        totalPayment - (Double(loanAmount) ?? 0)
    }
    
    var interestPercentage: Double {
        guard let principal = Double(loanAmount), principal > 0 else { return 0 }
        return (totalInterest / principal) * 100
    }
    
    var payoffBreakdown: [(year: Int, balance: Double, interest: Double, principal: Double)] {
        guard let loanPrincipal = Double(loanAmount),
              let rate = Double(interestRate),
              loanPrincipal > 0, rate > 0, totalMonths > 0 else { return [] }
        
        let monthlyRate = rate / 100 / 12
        var remainingBalance = loanPrincipal
        var breakdown: [(year: Int, balance: Double, interest: Double, principal: Double)] = []
        
        var currentYear = 1
        var yearlyInterest = 0.0
        var yearlyPrincipal = 0.0
        
        for month in 1...Int(totalMonths) {
            let interestPayment = remainingBalance * monthlyRate
            let principalPayment = monthlyPayment - interestPayment
            remainingBalance -= principalPayment
            
            yearlyInterest += interestPayment
            yearlyPrincipal += principalPayment
            
            if month % 12 == 0 || month == Int(totalMonths) {
                breakdown.append((
                    year: currentYear,
                    balance: max(0, remainingBalance),
                    interest: yearlyInterest,
                    principal: yearlyPrincipal
                ))
                
                currentYear += 1
                yearlyInterest = 0
                yearlyPrincipal = 0
            }
        }
        
        return breakdown
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(
                title: "Loan Calculator",
                description: "Calculate loan payments and interest"
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
                    
                    // Loan Type Selection
                    GroupedInputFields(
                        title: "Loan Type",
                        icon: "doc.text.fill",
                        color: .purple
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Loan Type", selection: $loanType) {
                                ForEach(LoanType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text("Typical rates: \(loanType.typicalRate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Loan Details
                    GroupedInputFields(
                        title: "Loan Details",
                        icon: "banknote.fill",
                        color: .blue
                    ) {
                        ModernInputField(
                            title: "Loan Amount",
                            value: $loanAmount,
                            placeholder: "25,000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Total amount you want to borrow",
                            onNext: { focusNextField(.loanAmount) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .loanAmount)
                        .id(LoanField.loanAmount)
                        
                        ModernInputField(
                            title: "Interest Rate (APR)",
                            value: $interestRate,
                            placeholder: "6.5",
                            suffix: "%",
                            icon: "percent",
                            color: .orange,
                            keyboardType: .decimalPad,
                            helpText: "Annual percentage rate from lender",
                            onPrevious: { focusPreviousField(.interestRate) },
                            onNext: { focusNextField(.interestRate) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .interestRate)
                        .id(LoanField.interestRate)
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Loan Term",
                                value: $loanTerm,
                                placeholder: "5",
                                color: .blue,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.loanTerm) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .loanTerm)
                            .id(LoanField.loanTerm)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Term Unit")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
                                Picker("Term Unit", selection: $termUnit) {
                                    ForEach(TermUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate Loan") {
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
                    if showResults && monthlyPayment > 0 {
                        VStack(spacing: 20) {
                            Divider()
                                .id("results")
                            
                            Text("Loan Summary")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Main Results
                            VStack(spacing: 12) {
                                CalculatorResultCard(
                                    title: "Monthly Payment",
                                    value: NumberFormatter.formatCurrency(monthlyPayment),
                                    subtitle: "\(Int(totalMonths)) payments",
                                    color: .blue
                                )
                                
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Total Interest",
                                        value: NumberFormatter.formatCurrency(totalInterest),
                                        subtitle: String(format: "%.1f%% of loan", interestPercentage),
                                        color: .orange
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Total Payment",
                                        value: NumberFormatter.formatCurrency(totalPayment),
                                        color: .purple
                                    )
                                }
                            }
                            
                            // Loan Details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Loan Details")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Loan Amount",
                                        value: NumberFormatter.formatCurrency(Double(loanAmount) ?? 0)
                                    )
                                    InfoRow(
                                        label: "Interest Rate (APR)",
                                        value: "\(interestRate)%"
                                    )
                                    InfoRow(
                                        label: "Loan Term",
                                        value: "\(loanTerm) \(termUnit.rawValue)"
                                    )
                                    InfoRow(
                                        label: "Number of Payments",
                                        value: "\(Int(totalMonths))"
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Cost Comparison
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cost Analysis")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Principal (what you borrow)",
                                        value: NumberFormatter.formatCurrency(Double(loanAmount) ?? 0)
                                    )
                                    InfoRow(
                                        label: "Interest (what you pay extra)",
                                        value: NumberFormatter.formatCurrency(totalInterest)
                                    )
                                    Divider()
                                    InfoRow(
                                        label: "Total you'll pay",
                                        value: NumberFormatter.formatCurrency(totalPayment)
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemOrange).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Yearly Payoff Schedule (first 5 years)
                            if !payoffBreakdown.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Payoff Schedule")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(spacing: 6) {
                                        ForEach(payoffBreakdown.prefix(5), id: \.year) { item in
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack {
                                                    Text("Year \(item.year)")
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    Spacer()
                                                    Text("Balance: \(NumberFormatter.formatCurrency(item.balance))")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                HStack {
                                                    Text("Interest: \(NumberFormatter.formatCurrency(item.interest))")
                                                        .font(.caption)
                                                        .foregroundColor(.orange)
                                                    Spacer()
                                                    Text("Principal: \(NumberFormatter.formatCurrency(item.principal))")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        
                                        if payoffBreakdown.count > 5 {
                                            Text("... and \(payoffBreakdown.count - 5) more years")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBlue).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Tips for Better Rates
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Tips for Better Loan Terms")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Shop around with multiple lenders")
                                    Text("• Improve your credit score before applying")
                                    Text("• Consider a larger down payment to reduce loan amount")
                                    Text("• Choose shorter terms for lower total interest")
                                    Text("• Make extra payments toward principal when possible")
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
            LoanInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: LoanField) {
        let allFields = LoanField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: LoanField) {
        let allFields = LoanField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        loanAmount = "25000"
        interestRate = "8.5"
        loanTerm = "5"
        termUnit = .years
        loanType = .personal
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        loanAmount = ""
        interestRate = ""
        loanTerm = ""
        termUnit = .years
        loanType = .personal
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Loan Calculation Results:
        Loan Amount: $\(loanAmount)
        Interest Rate: \(interestRate)%
        Loan Term: \(loanTerm) \(termUnit.rawValue)
        Monthly Payment: \(NumberFormatter.formatCurrency(monthlyPayment))
        Total Interest: \(NumberFormatter.formatCurrency(totalInterest))
        Total Payment: \(NumberFormatter.formatCurrency(totalPayment))
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

struct LoanInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Loan Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines your monthly loan payment, total interest cost, and payoff schedule for any type of loan."
                        )
                        
                        InfoSection(
                            title: "Loan Types",
                            content: """
                            • Personal Loans: Unsecured loans for various purposes
                            • Auto Loans: Secured by the vehicle being purchased
                            • Home Loans: Secured by the property being purchased
                            • Student Loans: For education expenses, often with special terms
                            """
                        )
                        
                        InfoSection(
                            title: "Key Terms",
                            content: """
                            • APR: Annual Percentage Rate (interest + fees)
                            • Principal: The amount you borrow
                            • Term: Length of time to repay the loan
                            • Amortization: How payments are split between principal and interest
                            """
                        )
                        
                        InfoSection(
                            title: "Tips for Better Rates",
                            content: """
                            • Compare offers from multiple lenders
                            • Improve your credit score before applying
                            • Consider shorter terms to save on total interest
                            • Make extra payments toward principal when possible
                            • Shop for pre-approval to understand your options
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Loan Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}