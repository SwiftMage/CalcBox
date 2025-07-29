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
            VStack(spacing: 20) {
                // Loan Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Loan Details")
                        .font(.headline)
                    
                    CalculatorInputField(
                        title: "Home Price",
                        value: $homePrice,
                        placeholder: "400000",
                        suffix: "$"
                    )
                    
                    CalculatorInputField(
                        title: "Down Payment",
                        value: $downPayment,
                        placeholder: "80000",
                        suffix: "$"
                    )
                    
                    if !downPayment.isEmpty && !homePrice.isEmpty {
                        Text("\(NumberFormatter.formatPercent(downPaymentPercentage)) down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    CalculatorInputField(
                        title: "Interest Rate",
                        value: $interestRate,
                        placeholder: "6.5",
                        suffix: "%"
                    )
                    
                    CalculatorInputField(
                        title: "Loan Term",
                        value: $loanTerm,
                        placeholder: "30",
                        suffix: "years"
                    )
                }
                
                // Additional Costs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Additional Costs")
                        .font(.headline)
                    
                    CalculatorInputField(
                        title: "Annual Property Tax",
                        value: $propertyTax,
                        placeholder: "5000",
                        suffix: "$/year"
                    )
                    
                    CalculatorInputField(
                        title: "Annual Home Insurance",
                        value: $homeInsurance,
                        placeholder: "1200",
                        suffix: "$/year"
                    )
                    
                    CalculatorInputField(
                        title: "Monthly HOA Fees",
                        value: $hoa,
                        placeholder: "200",
                        suffix: "$/month"
                    )
                    
                    if downPaymentPercentage < 20 {
                        CalculatorInputField(
                            title: "Monthly PMI",
                            value: $pmi,
                            placeholder: "200",
                            suffix: "$/month"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Payment") {
                    calculateAmortization()
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 20) {
                        Divider()
                        
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
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Loan Amount",
                                value: NumberFormatter.formatCurrency(loanAmount),
                                color: .orange
                            )
                            
                            CalculatorResultCard(
                                title: "Total Interest",
                                value: NumberFormatter.formatCurrency(totalInterest),
                                color: .red
                            )
                        }
                        
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

#Preview {
    NavigationStack {
        MortgageCalculatorView()
    }
}