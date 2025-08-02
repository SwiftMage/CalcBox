import SwiftUI

struct RetirementSavingsView: View {
    @State private var savingsAmount = ""
    @State private var yearlyReturn = ""
    @State private var withdrawalType = WithdrawalType.percentage
    @State private var withdrawalPercentage = ""
    @State private var withdrawalFixed = ""
    
    @State private var showResults = false
    @State private var yearlyBreakdown: [YearlyBreakdown] = []
    @State private var totalYears = 0
    @State private var isDemoActive = false
    
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
        CalculatorView(
            title: "Retirement Savings",
            description: "Calculate how long your retirement savings will last"
        ) {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Total Savings",
                    value: $savingsAmount,
                    placeholder: "500000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Yearly Return Rate",
                    value: $yearlyReturn,
                    placeholder: "5",
                    suffix: "%"
                )
                
                SegmentedPicker(
                    title: "Withdrawal Type",
                    selection: $withdrawalType,
                    options: WithdrawalType.allCases.map { ($0, $0.displayName) }
                )
                
                if withdrawalType == .percentage {
                    CalculatorInputField(
                        title: "Annual Withdrawal",
                        value: $withdrawalPercentage,
                        placeholder: "4",
                        suffix: "%"
                    )
                } else {
                    CalculatorInputField(
                        title: "Annual Withdrawal",
                        value: $withdrawalFixed,
                        placeholder: "30000",
                        suffix: "$"
                    )
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    CalculatorButton(title: isDemoActive ? "Clear Demo" : "Try Demo", style: .secondary) {
                        if isDemoActive {
                            clearDemoData()
                        } else {
                            fillDemoData()
                        }
                    }
                    
                    CalculatorButton(title: "Calculate") {
                        calculateBreakdown()
                        withAnimation {
                            showResults = true
                        }
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
                        
                        // Summary Box
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Your savings will last")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            if totalYears > 0 {
                                Text("\(totalYears) years")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            } else {
                                Text("Indefinitely")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            if let firstYear = yearlyBreakdown.first {
                                InfoRow(
                                    label: "First Year Withdrawal",
                                    value: NumberFormatter.formatCurrency(firstYear.withdrawal)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
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
            }
        }
    }
    
    private func fillDemoData() {
        savingsAmount = "1000000"
        yearlyReturn = "6"
        withdrawalType = .percentage
        withdrawalPercentage = "4"
        withdrawalFixed = "40000"
        isDemoActive = true
        
        // Auto-calculate after filling demo data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            calculateBreakdown()
            withAnimation {
                showResults = true
            }
        }
    }
    
    private func clearDemoData() {
        savingsAmount = ""
        yearlyReturn = ""
        withdrawalPercentage = ""
        withdrawalFixed = ""
        isDemoActive = false
        
        withAnimation {
            showResults = false
        }
        yearlyBreakdown = []
        totalYears = 0
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


#Preview {
    NavigationStack {
        RetirementSavingsView()
    }
}