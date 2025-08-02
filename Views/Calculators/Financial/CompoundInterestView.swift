import SwiftUI
import Charts

struct CompoundInterestView: View {
    @State private var principal = ""
    @State private var monthlyContribution = ""
    @State private var interestRate = ""
    @State private var years = ""
    @State private var compoundFrequency = CompoundFrequency.monthly
    
    @State private var showResults = false
    @State private var yearlyBreakdown: [YearlyBreakdown] = []
    @State private var isDemoActive = false
    @State private var showInfo = false
    
    enum CompoundFrequency: Int, CaseIterable {
        case annually = 1
        case semiAnnually = 2
        case quarterly = 4
        case monthly = 12
        case daily = 365
        
        var displayName: String {
            switch self {
            case .annually: return "Annually"
            case .semiAnnually: return "Semi-Annually"
            case .quarterly: return "Quarterly"
            case .monthly: return "Monthly"
            case .daily: return "Daily"
            }
        }
    }
    
    struct YearlyBreakdown: Identifiable {
        let id = UUID()
        let year: Int
        let principal: Double
        let interest: Double
        let total: Double
    }
    
    var totalAmount: Double {
        guard let p = Double(principal),
              let c = Double(monthlyContribution),
              let r = Double(interestRate),
              let t = Double(years),
              p >= 0, c >= 0, r >= 0, t > 0 else { return 0 }
        
        let rate = r / 100
        let n = Double(compoundFrequency.rawValue)
        
        // Compound interest for initial principal
        let principalGrowth = p * pow(1 + rate/n, n * t)
        
        // Future value of monthly contributions
        let monthlyRate = rate / 12
        let months = t * 12
        let contributionGrowth = c * ((pow(1 + monthlyRate, months) - 1) / monthlyRate)
        
        return principalGrowth + contributionGrowth
    }
    
    var totalContributions: Double {
        guard let p = Double(principal),
              let c = Double(monthlyContribution),
              let t = Double(years) else { return 0 }
        
        return p + (c * t * 12)
    }
    
    var totalInterest: Double {
        totalAmount - totalContributions
    }
    
    var body: some View {
        CalculatorView(
            title: "Compound Interest",
            description: "Calculate how your investment grows over time"
        ) {
            VStack(spacing: 20) {
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
                
                // Input Fields
                CalculatorInputField(
                    title: "Initial Investment",
                    value: $principal,
                    placeholder: "10000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Monthly Contribution",
                    value: $monthlyContribution,
                    placeholder: "500",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Annual Interest Rate",
                    value: $interestRate,
                    placeholder: "7",
                    suffix: "%"
                )
                
                CalculatorInputField(
                    title: "Investment Period",
                    value: $years,
                    placeholder: "10",
                    suffix: "years"
                )
                
                SegmentedPicker(
                    title: "Compound Frequency",
                    selection: $compoundFrequency,
                    options: CompoundFrequency.allCases.map { ($0, $0.displayName) }
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Growth") {
                    calculateBreakdown()
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Total Value",
                                value: NumberFormatter.formatCurrency(totalAmount),
                                color: .green
                            )
                            
                            CalculatorResultCard(
                                title: "Total Interest",
                                value: NumberFormatter.formatCurrency(totalInterest),
                                color: .blue
                            )
                        }
                        
                        // Growth Chart
                        if !yearlyBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Growth Over Time")
                                    .font(.headline)
                                
                                Chart(yearlyBreakdown) { item in
                                    AreaMark(
                                        x: .value("Year", item.year),
                                        y: .value("Amount", item.total)
                                    )
                                    .foregroundStyle(
                                        .linearGradient(
                                            colors: [.blue.opacity(0.6), .blue.opacity(0.2)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    
                                    LineMark(
                                        x: .value("Year", item.year),
                                        y: .value("Amount", item.principal)
                                    )
                                    .foregroundStyle(.gray)
                                    .lineStyle(StrokeStyle(dash: [5, 5]))
                                }
                                .frame(height: 250)
                                .chartXAxisLabel("Years")
                                .chartYAxisLabel("Value ($)")
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine()
                                        AxisTick()
                                        AxisValueLabel {
                                            if let amount = value.as(Double.self) {
                                                Text(NumberFormatter.formatCurrency(amount))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Summary
                        VStack(spacing: 8) {
                            InfoRow(
                                label: "Total Contributions",
                                value: NumberFormatter.formatCurrency(totalContributions)
                            )
                            InfoRow(
                                label: "Interest Earned",
                                value: NumberFormatter.formatCurrency(totalInterest)
                            )
                            InfoRow(
                                label: "Return on Investment",
                                value: NumberFormatter.formatPercent(totalInterest / totalContributions * 100)
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            CompoundInterestInfoSheet()
        }
    }
    
    private func fillDemoData() {
        principal = "10000"
        monthlyContribution = "500"
        interestRate = "7.0"
        years = "25"
        compoundFrequency = .monthly
        isDemoActive = true
    }
    
    private func fillDemoDataAndCalculate() {
        fillDemoData()
        calculateBreakdown()
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        clearDemoData()
    }
    
    private func clearDemoData() {
        principal = ""
        monthlyContribution = ""
        interestRate = ""
        years = ""
        compoundFrequency = .monthly
        isDemoActive = false
        
        withAnimation {
            showResults = false
        }
        yearlyBreakdown = []
    }
    
    private func calculateBreakdown() {
        guard let p = Double(principal),
              let c = Double(monthlyContribution),
              let r = Double(interestRate),
              let t = Double(years),
              p >= 0, c >= 0, r >= 0, t > 0 else {
            yearlyBreakdown = []
            return
        }
        
        var breakdown: [YearlyBreakdown] = []
        let rate = r / 100
        let n = Double(compoundFrequency.rawValue)
        
        for year in 0...Int(t) {
            let yearDouble = Double(year)
            
            // Principal growth
            let principalGrowth = p * pow(1 + rate/n, n * yearDouble)
            
            // Contribution growth
            let monthlyRate = rate / 12
            let months = yearDouble * 12
            let contributionGrowth = c * ((pow(1 + monthlyRate, months) - 1) / monthlyRate)
            
            let totalPrincipal = p + (c * yearDouble * 12)
            let total = principalGrowth + contributionGrowth
            
            breakdown.append(YearlyBreakdown(
                year: year,
                principal: totalPrincipal,
                interest: total - totalPrincipal,
                total: total
            ))
        }
        
        yearlyBreakdown = breakdown
    }
    
    private func shareResults() {
        let shareText = """
        Compound Interest Results:
        Initial Investment: $\(principal)
        Monthly Contribution: $\(monthlyContribution)
        Annual Rate: \(interestRate)%
        Investment Period: \(years) years
        Final Value: \(NumberFormatter.formatCurrency(totalAmount))
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

struct CompoundInterestInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Compound Interest Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "How it works",
                            content: "Compound interest is interest calculated on the initial principal and also on the accumulated interest from previous periods. This calculator shows how your investment grows over time with regular contributions."
                        )
                        
                        InfoSection(
                            title: "Key Concepts",
                            content: """
                            • Principal: Your initial investment amount
                            • Contributions: Regular monthly deposits
                            • Interest Rate: Annual percentage return
                            • Compounding: How often interest is calculated
                            • Time: Investment period in years
                            """
                        )
                        
                        InfoSection(
                            title: "Investment Tips",
                            content: """
                            • Start investing early to maximize compounding
                            • Make regular contributions consistently
                            • Higher compound frequency = more growth
                            • Time in market beats timing the market
                            • Consider tax-advantaged accounts (401k, IRA)
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Investment Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        CompoundInterestView()
    }
}