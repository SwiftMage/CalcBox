import SwiftUI
import Charts

struct MortgageCalculatorView: View {
    @State private var homePrice = ""
    @State private var downPayment = ""
    @State private var interestRate = ""
    @State private var loanTerm = ""
    @State private var propertyTax = ""
    @State private var homeInsurance = ""
    @State private var hoa = ""
    @State private var pmi = ""
    
    @State private var showResults = false
    @State private var amortizationSchedule: [AmortizationItem] = []
    @State private var showInfo = false
    @FocusState private var focusedField: MortgageField?
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    enum MortgageField: CaseIterable {
        case homePrice, downPayment, interestRate, loanTerm, propertyTax, homeInsurance, hoa, pmi
    }
    
    struct AmortizationItem: Identifiable {
        let id = UUID()
        let month: Int
        let payment: Double
        let principal: Double
        let interest: Double
        let balance: Double
    }
    
    var loanAmount: Double {
        guard let price = Double(homePrice),
              let down = Double(downPayment) else { return 0 }
        return max(0, price - down)
    }
    
    var downPaymentPercentage: Double {
        guard let price = Double(homePrice),
              let down = Double(downPayment),
              price > 0 else { return 0 }
        return (down / price) * 100
    }
    
    var monthlyPrincipalAndInterest: Double {
        guard let r = Double(interestRate),
              let n = Double(loanTerm),
              loanAmount > 0, r > 0, n > 0 else { return 0 }
        
        let monthlyRate = r / 100 / 12
        let months = n * 12
        
        return loanAmount * (monthlyRate * pow(1 + monthlyRate, months)) / (pow(1 + monthlyRate, months) - 1)
    }
    
    var monthlyPropertyTax: Double {
        (Double(propertyTax) ?? 0) / 12
    }
    
    var monthlyInsurance: Double {
        (Double(homeInsurance) ?? 0) / 12
    }
    
    var monthlyHOA: Double {
        Double(hoa) ?? 0
    }
    
    var monthlyPMI: Double {
        downPaymentPercentage < 20 ? (Double(pmi) ?? 0) : 0
    }
    
    var totalMonthlyPayment: Double {
        monthlyPrincipalAndInterest + monthlyPropertyTax + monthlyInsurance + monthlyHOA + monthlyPMI
    }
    
    var totalInterest: Double {
        guard let n = Double(loanTerm), n > 0 else { return 0 }
        return (monthlyPrincipalAndInterest * n * 12) - loanAmount
    }
    
    var body: some View {
        CalculatorView(
            title: "Mortgage Calculator",
            description: "Calculate your monthly mortgage payment"
        ) {
            ScrollViewReader { proxy in
            VStack(spacing: 24) {
                // Quick Action Buttons
                HStack(spacing: 8) {
                    QuickActionButton(
                        icon: "wand.and.stars.inverse",
                        title: "Example",
                        color: .blue
                    ) {
                        fillDemoDataAndCalculate()
                    }
                    
                    QuickActionButton(
                        icon: "trash",
                        title: "Clear",
                        color: .red
                    ) {
                        clearAllData()
                    }
                    
                    QuickActionButton(
                        icon: "info.circle",
                        title: "Info",
                        color: .gray
                    ) {
                        showInfo = true
                    }
                    
                    if showResults {
                        QuickActionButton(
                            icon: "square.and.arrow.up",
                            title: "Share",
                            color: .green
                        ) {
                            shareResults()
                        }
                    }
                }
                
                // Loan Details
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .frame(width: 24)
                        
                        Text("Loan Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    DecimalPadInputField(
                        title: "Home Price",
                        text: $homePrice,
                        placeholder: "400,000",
                        suffix: nil,
                        prefix: "$",
                        onNext: { focusNextField(.homePrice) },
                        onDone: { focusedField = nil },
                        isCurrency: true
                    )
                    .focused($focusedField, equals: .homePrice)
                    .id(MortgageField.homePrice)
                    
                    DecimalPadInputField(
                        title: "Down Payment",
                        text: $downPayment,
                        placeholder: "80,000",
                        suffix: nil,
                        prefix: "$",
                        onNext: { focusNextField(.downPayment) },
                        onDone: { focusedField = nil },
                        isCurrency: true
                    )
                    .focused($focusedField, equals: .downPayment)
                    .id(MortgageField.downPayment)
                    
                    if !downPayment.isEmpty && !homePrice.isEmpty {
                        HStack {
                            Image(systemName: "percent")
                                .foregroundColor(.orange)
                            Text("Down Payment: \(NumberFormatter.formatPercent(downPaymentPercentage))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    HStack(spacing: 16) {
                        DecimalPadInputField(
                            title: "Interest Rate",
                            text: $interestRate,
                            placeholder: "6.5",
                            suffix: "%",
                            prefix: nil,
                            onNext: { focusNextField(.interestRate) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .interestRate)
                        .id(MortgageField.interestRate)
                        
                        DecimalPadInputField(
                            title: "Loan Term",
                            text: $loanTerm,
                            placeholder: "30",
                            suffix: "years",
                            prefix: nil,
                            onNext: { focusNextField(.loanTerm) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .loanTerm)
                        .id(MortgageField.loanTerm)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                
                // Additional Costs
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                            .frame(width: 24)
                        
                        Text("Additional Monthly Costs")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    DecimalPadInputField(
                        title: "Annual Property Tax",
                        text: $propertyTax,
                        placeholder: "5,000",
                        suffix: nil,
                        prefix: "$",
                        onNext: { focusNextField(.propertyTax) },
                        onDone: { focusedField = nil },
                        isCurrency: true
                    )
                    .focused($focusedField, equals: .propertyTax)
                    .id(MortgageField.propertyTax)
                    
                    DecimalPadInputField(
                        title: "Annual Home Insurance",
                        text: $homeInsurance,
                        placeholder: "1,200",
                        suffix: nil,
                        prefix: "$",
                        onNext: { focusNextField(.homeInsurance) },
                        onDone: { focusedField = nil },
                        isCurrency: true
                    )
                    .focused($focusedField, equals: .homeInsurance)
                    .id(MortgageField.homeInsurance)
                    
                    DecimalPadInputField(
                        title: "Monthly HOA Fees",
                        text: $hoa,
                        placeholder: "200",
                        suffix: nil,
                        prefix: "$",
                        onNext: { focusNextField(.hoa) },
                        onDone: { focusedField = nil },
                        isCurrency: true
                    )
                    .focused($focusedField, equals: .hoa)
                    .id(MortgageField.hoa)
                    
                    if downPaymentPercentage < 20 {
                        DecimalPadInputField(
                            title: "Monthly PMI",
                            text: $pmi,
                            placeholder: "200",
                            suffix: nil,
                            prefix: "$",
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false,
                            isCurrency: true
                        )
                        .focused($focusedField, equals: .pmi)
                        .id(MortgageField.pmi)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly PMI")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Not Required (20%+ down payment)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Payment") {
                    calculateAmortization()
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
                        
                        Text("Monthly Payment Breakdown")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Payment Breakdown Chart
                        PaymentBreakdownChart(
                            principal: monthlyPrincipalAndInterest,
                            propertyTax: monthlyPropertyTax,
                            insurance: monthlyInsurance,
                            hoa: monthlyHOA,
                            pmi: monthlyPMI
                        )
                        
                        // Total Monthly Payment
                        CalculatorResultCard(
                            title: "Total Monthly Payment",
                            value: NumberFormatter.formatCurrency(totalMonthlyPayment),
                            subtitle: "Principal & Interest: \(NumberFormatter.formatCurrency(monthlyPrincipalAndInterest))",
                            color: .blue
                        )
                        
                        // Loan Summary
                        HStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "Loan Amount",
                                value: NumberFormatter.formatCurrency(loanAmount),
                                color: .orange
                            )
                            .minimumScaleFactor(0.8)
                            
                            CalculatorResultCard(
                                title: "Total Interest",
                                value: NumberFormatter.formatCurrency(totalInterest),
                                color: .red
                            )
                            .minimumScaleFactor(0.8)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        
                        // Amortization Preview
                        if !amortizationSchedule.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Principal vs Interest Over Time")
                                    .font(.headline)
                                
                                Chart(amortizationSchedule.filter { $0.month % 12 == 0 }) { item in
                                    BarMark(
                                        x: .value("Year", item.month / 12),
                                        y: .value("Amount", item.principal)
                                    )
                                    .foregroundStyle(.blue)
                                    
                                    BarMark(
                                        x: .value("Year", item.month / 12),
                                        y: .value("Amount", item.interest)
                                    )
                                    .foregroundStyle(.red.opacity(0.7))
                                }
                                .frame(height: 200)
                                .chartXAxisLabel("Year")
                                .chartYAxisLabel("Monthly Payment ($)")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight - 50 : 0)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.keyboardHeight)
            .onChange(of: focusedField) { field in
                if let field = field {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
            }
        }
        .sheet(isPresented: $showInfo) {
            MortgageInfoSheet()
        }
    }
    
    private func calculateAmortization() {
        guard let r = Double(interestRate),
              let n = Double(loanTerm),
              loanAmount > 0, r > 0, n > 0 else {
            amortizationSchedule = []
            return
        }
        
        var schedule: [AmortizationItem] = []
        let monthlyRate = r / 100 / 12
        let months = Int(n * 12)
        var balance = loanAmount
        
        for month in 1...months {
            let interestPayment = balance * monthlyRate
            let principalPayment = monthlyPrincipalAndInterest - interestPayment
            balance -= principalPayment
            
            schedule.append(AmortizationItem(
                month: month,
                payment: monthlyPrincipalAndInterest,
                principal: principalPayment,
                interest: interestPayment,
                balance: max(0, balance)
            ))
        }
        
        amortizationSchedule = schedule
    }
    
    private func focusNextField(_ currentField: MortgageField) {
        let allFields = MortgageField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        homePrice = "400000"
        downPayment = "80000"
        interestRate = "6.5"
        loanTerm = "30"
        propertyTax = "5000"
        homeInsurance = "1200"
        hoa = "200"
        pmi = "200"
        
        calculateAmortization()
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        homePrice = ""
        downPayment = ""
        interestRate = ""
        loanTerm = ""
        propertyTax = ""
        homeInsurance = ""
        hoa = ""
        pmi = ""
        
        withAnimation {
            showResults = false
        }
        amortizationSchedule = []
    }
    
    private func shareResults() {
        let shareText = """
        Mortgage Calculation Results:
        Home Price: $\(homePrice)
        Down Payment: $\(downPayment) (\(NumberFormatter.formatPercent(downPaymentPercentage)))
        Monthly Payment: \(NumberFormatter.formatCurrency(totalMonthlyPayment))
        Total Interest: \(NumberFormatter.formatCurrency(totalInterest))
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

struct PaymentBreakdownChart: View {
    let principal: Double
    let propertyTax: Double
    let insurance: Double
    let hoa: Double
    let pmi: Double
    
    var total: Double {
        principal + propertyTax + insurance + hoa + pmi
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(paymentComponents, id: \.label) { component in
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(component.color)
                        .frame(width: 4, height: 20)
                    
                    Text(component.label)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(NumberFormatter.formatCurrency(component.amount))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(component.color.opacity(0.2))
                        .frame(width: geometry.size.width, height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(component.color)
                        .frame(width: geometry.size.width * (component.amount / total), height: 8)
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var paymentComponents: [(label: String, amount: Double, color: Color)] {
        var components: [(String, Double, Color)] = []
        
        if principal > 0 {
            components.append(("Principal & Interest", principal, .blue))
        }
        if propertyTax > 0 {
            components.append(("Property Tax", propertyTax, .green))
        }
        if insurance > 0 {
            components.append(("Home Insurance", insurance, .orange))
        }
        if hoa > 0 {
            components.append(("HOA Fees", hoa, .purple))
        }
        if pmi > 0 {
            components.append(("PMI", pmi, .red))
        }
        
        return components
    }
}

struct MortgageInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Mortgage Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines your monthly mortgage payment including principal, interest, property tax, insurance, HOA fees, and PMI."
                        )
                        
                        InfoSection(
                            title: "Key Terms",
                            content: """
                            • Principal & Interest: Core loan payment
                            • PMI: Required if down payment < 20%
                            • Property Tax: Annual tax ÷ 12 months
                            • HOA: Homeowners Association fees
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • Aim for 20% down payment to avoid PMI
                            • Total housing costs should be ≤ 28% of income
                            • Consider all costs: maintenance, utilities, etc.
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Mortgage Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        MortgageCalculatorView()
    }
}