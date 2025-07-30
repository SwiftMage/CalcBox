import SwiftUI

// This file contains placeholder views for calculators that haven't been implemented yet
// Each view can be replaced with a full implementation later

// Financial Placeholders
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
        CalculatorView(title: "Paycheck Calculator", description: "Calculate take-home pay after taxes") {
            VStack(spacing: 20) {
                // Basic Income Info
                CalculatorInputField(
                    title: "Annual Salary",
                    value: $salary,
                    placeholder: "75000",
                    suffix: "$"
                )
                
                SegmentedPicker(
                    title: "Pay Frequency",
                    selection: $payFrequency,
                    options: PayFrequency.allCases.map { ($0, $0.rawValue) }
                )
                
                // Tax Withholdings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tax Withholdings (%)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Federal Income Tax",
                            value: $federalWithholding,
                            placeholder: "22",
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "State Income Tax",
                            value: $stateWithholding,
                            placeholder: "5",
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "Social Security",
                            value: $socialSecurity,
                            placeholder: "6.2",
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "Medicare",
                            value: $medicare,
                            placeholder: "1.45",
                            suffix: "%"
                        )
                    }
                }
                
                // Pre-tax Deductions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deductions (Per Pay Period)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Health Insurance",
                            value: $healthInsurance,
                            placeholder: "150",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "401(k) Contribution",
                            value: $retirement401k,
                            placeholder: "10",
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "Other Deductions",
                            value: $otherDeductions,
                            placeholder: "50",
                            suffix: "$"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Paycheck") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && netPayPerPeriod > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
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
        }
    }
}

struct NetWorthView: View {
    @State private var assets: [AssetItem] = [AssetItem()]
    @State private var liabilities: [LiabilityItem] = [LiabilityItem()]
    @State private var showResults = false
    
    struct AssetItem: Identifiable {
        let id = UUID()
        var name = ""
        var value = ""
        var category = AssetCategory.cash
    }
    
    struct LiabilityItem: Identifiable {
        let id = UUID()
        var name = ""
        var value = ""
        var category = LiabilityCategory.debt
    }
    
    enum AssetCategory: String, CaseIterable {
        case cash = "Cash & Savings"
        case investments = "Investments"
        case realEstate = "Real Estate"
        case retirement = "Retirement Accounts"
        case personal = "Personal Property"
        case other = "Other Assets"
    }
    
    enum LiabilityCategory: String, CaseIterable {
        case debt = "Credit Card Debt"
        case mortgage = "Mortgage"
        case studentLoan = "Student Loans"
        case autoLoan = "Auto Loans"
        case other = "Other Debts"
    }
    
    var totalAssets: Double {
        assets.compactMap { Double($0.value) }.reduce(0, +)
    }
    
    var totalLiabilities: Double {
        liabilities.compactMap { Double($0.value) }.reduce(0, +)
    }
    
    var netWorth: Double {
        totalAssets - totalLiabilities
    }
    
    var assetsByCategory: [(category: AssetCategory, total: Double)] {
        AssetCategory.allCases.map { category in
            let total = assets.filter { $0.category == category && !$0.value.isEmpty }
                           .compactMap { Double($0.value) }
                           .reduce(0, +)
            return (category, total)
        }.filter { $0.total > 0 }
    }
    
    var liabilitiesByCategory: [(category: LiabilityCategory, total: Double)] {
        LiabilityCategory.allCases.map { category in
            let total = liabilities.filter { $0.category == category && !$0.value.isEmpty }
                                  .compactMap { Double($0.value) }
                                  .reduce(0, +)
            return (category, total)
        }.filter { $0.total > 0 }
    }
    
    var netWorthRating: (rating: String, color: Color, description: String) {
        switch netWorth {
        case ..<0:
            return ("Needs Improvement", .red, "Focus on debt reduction and building assets")
        case 0..<10000:
            return ("Getting Started", .orange, "You're on the right track, keep building")
        case 10000..<50000:
            return ("Building Wealth", .yellow, "Good progress toward financial security")
        case 50000..<100000:
            return ("Strong Position", .blue, "You're building significant wealth")
        case 100000..<500000:
            return ("Excellent", .green, "Strong financial foundation")
        default:
            return ("Outstanding", .purple, "Exceptional wealth accumulation")
        }
    }
    
    var body: some View {
        CalculatorView(title: "Net Worth", description: "Track assets and liabilities") {
            VStack(spacing: 20) {
                // Assets Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Assets")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                        Button("Add Asset") {
                            assets.append(AssetItem())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(assets.indices, id: \.self) { index in
                        AssetRowView(
                            asset: $assets[index],
                            onDelete: {
                                if assets.count > 1 {
                                    assets.remove(at: index)
                                }
                            }
                        )
                    }
                }
                
                Divider()
                
                // Liabilities Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Liabilities")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                        Button("Add Liability") {
                            liabilities.append(LiabilityItem())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(liabilities.indices, id: \.self) { index in
                        LiabilityRowView(
                            liability: $liabilities[index],
                            onDelete: {
                                if liabilities.count > 1 {
                                    liabilities.remove(at: index)
                                }
                            }
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Net Worth") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Net Worth Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Net Worth Result
                        CalculatorResultCard(
                            title: "Net Worth",
                            value: NumberFormatter.formatCurrency(netWorth),
                            subtitle: netWorthRating.rating,
                            color: netWorthRating.color
                        )
                        
                        // Rating Description
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(netWorthRating.color)
                            Text(netWorthRating.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(netWorthRating.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Summary
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Total Assets",
                                value: NumberFormatter.formatCurrency(totalAssets),
                                color: .green
                            )
                            
                            CalculatorResultCard(
                                title: "Total Liabilities",
                                value: NumberFormatter.formatCurrency(totalLiabilities),
                                color: .red
                            )
                        }
                        
                        // Asset Breakdown
                        if !assetsByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Assets by Category")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    ForEach(assetsByCategory, id: \.category) { item in
                                        InfoRow(
                                            label: item.category.rawValue,
                                            value: NumberFormatter.formatCurrency(item.total)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Liability Breakdown
                        if !liabilitiesByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Liabilities by Category")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    ForEach(liabilitiesByCategory, id: \.category) { item in
                                        InfoRow(
                                            label: item.category.rawValue,
                                            value: NumberFormatter.formatCurrency(item.total)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemRed).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Tips for Improvement
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Tips to Improve Net Worth")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if netWorth < 0 {
                                    Text("• Focus on paying down high-interest debt first")
                                        .fontWeight(.medium)
                                }
                                Text("• Build an emergency fund (3-6 months expenses)")
                                Text("• Maximize employer 401(k) matching")
                                Text("• Consider low-cost index fund investments")
                                Text("• Track your net worth monthly to monitor progress")
                                Text("• Avoid lifestyle inflation as income increases")
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
        }
    }
}

struct AssetRowView: View {
    @Binding var asset: NetWorthView.AssetItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Asset Name", text: $asset.name)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $asset.category) {
                        ForEach(NetWorthView.AssetCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("$0", text: $asset.value)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color(.systemGreen).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LiabilityRowView: View {
    @Binding var liability: NetWorthView.LiabilityItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Liability Name", text: $liability.name)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $liability.category) {
                        ForEach(NetWorthView.LiabilityCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount Owed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("$0", text: $liability.value)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color(.systemRed).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InvestmentReturnsView: View {
    @State private var initialInvestment = ""
    @State private var currentValue = ""
    @State private var additionalContributions = ""
    @State private var timeHeld = ""
    @State private var timeUnit = TimeUnit.years
    @State private var showResults = false
    
    enum TimeUnit: String, CaseIterable {
        case years = "Years"
        case months = "Months"
        case days = "Days"
        
        var yearsMultiplier: Double {
            switch self {
            case .years: return 1.0
            case .months: return 1.0 / 12.0
            case .days: return 1.0 / 365.0
            }
        }
    }
    
    var totalInvested: Double {
        (Double(initialInvestment) ?? 0) + (Double(additionalContributions) ?? 0)
    }
    
    var currentPortfolioValue: Double {
        Double(currentValue) ?? 0
    }
    
    var totalReturn: Double {
        currentPortfolioValue - totalInvested
    }
    
    var returnPercentage: Double {
        guard totalInvested > 0 else { return 0 }
        return (totalReturn / totalInvested) * 100
    }
    
    var timeInYears: Double {
        guard let time = Double(timeHeld) else { return 0 }
        return time * timeUnit.yearsMultiplier
    }
    
    var annualizedReturn: Double {
        guard totalInvested > 0, timeInYears > 0 else { return 0 }
        return (pow(currentPortfolioValue / totalInvested, 1.0 / timeInYears) - 1) * 100
    }
    
    var performanceRating: (rating: String, color: Color, description: String) {
        let annualized = annualizedReturn
        switch annualized {
        case ..<0:
            return ("Loss", .red, "Portfolio has declined in value")
        case 0..<3:
            return ("Poor", .orange, "Below inflation, consider reassessing strategy")
        case 3..<7:
            return ("Below Average", .yellow, "Modest returns, room for improvement")
        case 7..<10:
            return ("Good", .blue, "Solid returns, meeting market expectations")
        case 10..<15:
            return ("Excellent", .green, "Strong performance, above market average")
        default:
            return ("Outstanding", .purple, "Exceptional returns, review for sustainability")
        }
    }
    
    var body: some View {
        CalculatorView(title: "Investment Returns", description: "Track portfolio performance") {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Initial Investment",
                    value: $initialInvestment,
                    placeholder: "10000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Additional Contributions",
                    value: $additionalContributions,
                    placeholder: "5000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Current Portfolio Value",
                    value: $currentValue,
                    placeholder: "18500",
                    suffix: "$"
                )
                
                HStack(spacing: 16) {
                    CalculatorInputField(
                        title: "Time Held",
                        value: $timeHeld,
                        placeholder: "3",
                        keyboardType: .numberPad
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time Unit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Time Unit", selection: $timeUnit) {
                            ForEach(TimeUnit.allCases, id: \.self) { unit in
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
                
                // Calculate Button
                CalculatorButton(title: "Analyze Returns") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && currentPortfolioValue > 0 && totalInvested > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Investment Performance")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Performance Rating
                        CalculatorResultCard(
                            title: "Performance Rating",
                            value: performanceRating.rating,
                            subtitle: performanceRating.description,
                            color: performanceRating.color
                        )
                        
                        // Key Metrics
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Total Return",
                                    value: NumberFormatter.formatCurrency(totalReturn),
                                    subtitle: NumberFormatter.formatPercent(returnPercentage),
                                    color: totalReturn >= 0 ? .green : .red
                                )
                                
                                CalculatorResultCard(
                                    title: "Annualized Return",
                                    value: NumberFormatter.formatPercent(annualizedReturn),
                                    subtitle: "Per year average",
                                    color: annualizedReturn >= 0 ? .blue : .red
                                )
                            }
                        }
                        
                        // Investment Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Investment Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Initial Investment",
                                    value: NumberFormatter.formatCurrency(Double(initialInvestment) ?? 0)
                                )
                                InfoRow(
                                    label: "Additional Contributions",
                                    value: NumberFormatter.formatCurrency(Double(additionalContributions) ?? 0)
                                )
                                InfoRow(
                                    label: "Total Invested",
                                    value: NumberFormatter.formatCurrency(totalInvested)
                                )
                                InfoRow(
                                    label: "Current Value",
                                    value: NumberFormatter.formatCurrency(currentPortfolioValue)
                                )
                                InfoRow(
                                    label: "Time Period",
                                    value: "\(timeHeld) \(timeUnit.rawValue.lowercased()) (\(String(format: "%.1f", timeInYears)) years)"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Investment Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Past performance doesn't guarantee future results")
                                Text("• Diversify across asset classes and sectors")
                                Text("• Consider dollar-cost averaging for regular investing")
                                Text("• Review and rebalance portfolio periodically")
                                Text("• Keep investment costs and fees low")
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
        }
    }
}

struct RetirementPlanningView: View {
    @State private var currentAge = ""
    @State private var retirementAge = "65"
    @State private var currentSavings = ""
    @State private var monthlyContribution = ""
    @State private var employerMatch = ""
    @State private var expectedReturn = "7"
    @State private var desiredMonthlyIncome = ""
    @State private var showResults = false
    
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
        CalculatorView(title: "Retirement Planning", description: "401k and IRA calculations") {
            VStack(spacing: 20) {
                // Age Information
                HStack(spacing: 16) {
                    CalculatorInputField(
                        title: "Current Age",
                        value: $currentAge,
                        placeholder: "30",
                        keyboardType: .numberPad,
                        suffix: "years"
                    )
                    
                    CalculatorInputField(
                        title: "Retirement Age",
                        value: $retirementAge,
                        placeholder: "65",
                        keyboardType: .numberPad,
                        suffix: "years"
                    )
                }
                
                // Current Savings
                CalculatorInputField(
                    title: "Current Retirement Savings",
                    value: $currentSavings,
                    placeholder: "50000",
                    suffix: "$"
                )
                
                // Monthly Contributions
                CalculatorInputField(
                    title: "Monthly Contribution",
                    value: $monthlyContribution,
                    placeholder: "500",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Employer Match (Monthly)",
                    value: $employerMatch,
                    placeholder: "250",
                    suffix: "$"
                )
                
                // Investment Return
                CalculatorInputField(
                    title: "Expected Annual Return",
                    value: $expectedReturn,
                    placeholder: "7",
                    suffix: "%"
                )
                
                // Desired Income
                CalculatorInputField(
                    title: "Desired Monthly Retirement Income",
                    value: $desiredMonthlyIncome,
                    placeholder: "4000",
                    suffix: "$"
                )
                
                // Calculate Button
                CalculatorButton(title: "Plan Retirement") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && yearsUntilRetirement > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
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
                        
                        // Tips
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
        }
    }
}

struct LoanCalculatorView: View {
    @State private var loanAmount = ""
    @State private var interestRate = ""
    @State private var loanTerm = ""
    @State private var termUnit = TermUnit.years
    @State private var loanType = LoanType.personal
    @State private var showResults = false
    
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
    
    var body: some View {
        CalculatorView(title: "Loan Calculator", description: "Calculate loan payments and interest") {
            VStack(spacing: 20) {
                // Loan Type Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Loan Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
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
                
                // Input Fields
                CalculatorInputField(
                    title: "Loan Amount",
                    value: $loanAmount,
                    placeholder: "25000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Interest Rate (APR)",
                    value: $interestRate,
                    placeholder: "6.5",
                    suffix: "%"
                )
                
                HStack(spacing: 16) {
                    CalculatorInputField(
                        title: "Loan Term",
                        value: $loanTerm,
                        placeholder: "5",
                        keyboardType: .numberPad
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Term Unit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
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
                
                // Calculate Button
                CalculatorButton(title: "Calculate Loan") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && monthlyPayment > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
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
                        
                        // Tips
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
                                Text("• Consider a larger down payment")
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
        }
    }
}

struct BudgetPlannerView: View {
    @State private var monthlyIncome = ""
    @State private var budgetRule = BudgetRule.fiftyThirtyTwenty
    @State private var customNeeds = "50"
    @State private var customWants = "30"
    @State private var customSavings = "20"
    @State private var showResults = false
    
    enum BudgetRule: String, CaseIterable {
        case fiftyThirtyTwenty = "50/30/20 Rule"
        case sixtyTwentyTwenty = "60/20/20 Rule"
        case seventyTwentyTen = "70/20/10 Rule"
        case custom = "Custom Split"
        
        var description: String {
            switch self {
            case .fiftyThirtyTwenty: return "50% Needs, 30% Wants, 20% Savings"
            case .sixtyTwentyTwenty: return "60% Needs, 20% Wants, 20% Savings"
            case .seventyTwentyTen: return "70% Needs, 20% Wants, 10% Savings"
            case .custom: return "Set your own percentages"
            }
        }
        
        var percentages: (needs: Double, wants: Double, savings: Double) {
            switch self {
            case .fiftyThirtyTwenty: return (50, 30, 20)
            case .sixtyTwentyTwenty: return (60, 20, 20)
            case .seventyTwentyTen: return (70, 20, 10)
            case .custom: return (0, 0, 0) // Will use custom values
            }
        }
    }
    
    var income: Double {
        Double(monthlyIncome) ?? 0
    }
    
    var budgetPercentages: (needs: Double, wants: Double, savings: Double) {
        if budgetRule == .custom {
            return (
                Double(customNeeds) ?? 50,
                Double(customWants) ?? 30,
                Double(customSavings) ?? 20
            )
        } else {
            return budgetRule.percentages
        }
    }
    
    var budgetAmounts: (needs: Double, wants: Double, savings: Double) {
        let percentages = budgetPercentages
        return (
            income * (percentages.needs / 100),
            income * (percentages.wants / 100),
            income * (percentages.savings / 100)
        )
    }
    
    var body: some View {
        CalculatorView(title: "Budget Planner", description: "50/30/20 rule budget calculator") {
            VStack(spacing: 20) {
                // Income Input
                CalculatorInputField(
                    title: "Monthly Take-Home Income",
                    value: $monthlyIncome,
                    placeholder: "5000",
                    suffix: "$"
                )
                
                // Budget Rule Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Method")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Budget Rule", selection: $budgetRule) {
                        ForEach(BudgetRule.allCases, id: \.self) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(budgetRule.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Custom percentages (if custom rule selected)
                if budgetRule == .custom {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Percentages")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            CalculatorInputField(
                                title: "Needs",
                                value: $customNeeds,
                                placeholder: "50",
                                suffix: "%"
                            )
                            
                            CalculatorInputField(
                                title: "Wants",
                                value: $customWants,
                                placeholder: "30",
                                suffix: "%"
                            )
                            
                            CalculatorInputField(
                                title: "Savings",
                                value: $customSavings,
                                placeholder: "20",
                                suffix: "%"
                            )
                        }
                        
                        let total = (Double(customNeeds) ?? 0) + (Double(customWants) ?? 0) + (Double(customSavings) ?? 0)
                        if total != 100 {
                            Text("⚠️ Percentages should total 100% (currently \(Int(total))%)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Create Budget Plan") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && income > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Your Budget Plan")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Budget Overview
                        HStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "Needs (\(Int(budgetPercentages.needs))%)",
                                value: NumberFormatter.formatCurrency(budgetAmounts.needs),
                                color: .red
                            )
                            
                            CalculatorResultCard(
                                title: "Wants (\(Int(budgetPercentages.wants))%)",
                                value: NumberFormatter.formatCurrency(budgetAmounts.wants),
                                color: .orange
                            )
                            
                            CalculatorResultCard(
                                title: "Savings (\(Int(budgetPercentages.savings))%)",
                                value: NumberFormatter.formatCurrency(budgetAmounts.savings),
                                color: .green
                            )
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Budgeting Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Track expenses for a month to see where your money goes")
                                Text("• Automate savings transfers to make it easier")
                                Text("• Review and adjust your budget monthly")
                                Text("• Build your emergency fund first, then other goals")
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
        }
    }
}

struct InflationCalculatorView: View {
    @State private var currentAmount = ""
    @State private var inflationRate = "3.0"
    @State private var timeYears = ""
    @State private var calculationType = InflationCalculationType.futureValue
    @State private var showResults = false
    
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
    
    var body: some View {
        CalculatorView(title: "Inflation Calculator", description: "Calculate purchasing power over time") {
            VStack(spacing: 20) {
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
                CalculatorInputField(
                    title: calculationType == .pastValue ? "Past Amount" : "Current Amount",
                    value: $currentAmount,
                    placeholder: "1000",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Annual Inflation Rate",
                    value: $inflationRate,
                    placeholder: "3.0",
                    suffix: "%"
                )
                
                CalculatorInputField(
                    title: "Time Period",
                    value: $timeYears,
                    placeholder: "10",
                    keyboardType: .numberPad,
                    suffix: "years"
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Inflation Impact") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && calculatedValue > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
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
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

// Travel Placeholders
struct MPGCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Miles Per Gallon", description: "Track fuel efficiency") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct TripTimeView: View {
    var body: some View {
        CalculatorView(title: "Trip Time", description: "Estimate travel duration") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

// Health Placeholders
struct CalorieBurnView: View {
    var body: some View {
        CalculatorView(title: "Calorie Burning", description: "Exercise calorie calculator") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct DrinkingCaloriesView: View {
    var body: some View {
        CalculatorView(title: "Drinking Calories", description: "Alcohol calorie calculator") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct OneRepMaxView: View {
    var body: some View {
        CalculatorView(title: "One Rep Max", description: "Weight lifting calculator") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct PregnancyCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Pregnancy Due Date", description: "Calculate estimated due date") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

// Utilities Placeholders
struct PhoneCostView: View {
    var body: some View {
        CalculatorView(title: "Phone Cost Per Minute", description: "Calculate phone usage costs") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct MonthlyBillsView: View {
    var body: some View {
        CalculatorView(title: "Monthly Bills", description: "Track recurring expenses") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct RentingCostView: View {
    var body: some View {
        CalculatorView(title: "Renting Cost", description: "Calculate true cost of renting") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

// Education Placeholders
struct GPACalculatorView: View {
    var body: some View {
        CalculatorView(title: "GPA Calculator", description: "Calculate grade point average") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct SchoolCostView: View {
    var body: some View {
        CalculatorView(title: "School Cost", description: "Calculate education expenses") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

// Lifestyle Placeholders
struct TipCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Tip Calculator", description: "Calculate tips and split bills") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct UnitConverterView: View {
    var body: some View {
        CalculatorView(title: "Unit Converter", description: "Convert between units") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct CurrencyConverterView: View {
    var body: some View {
        CalculatorView(title: "Currency Converter", description: "Convert between currencies") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct SalesTaxCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Sales Tax", description: "Calculate tax on purchases") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct PercentageCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Percentage Calculator", description: "Calculate percentages and changes") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

// Time & Date Placeholders
struct DateCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Date Calculator", description: "Calculate days between dates") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct TimeZoneConverterView: View {
    var body: some View {
        CalculatorView(title: "Time Zone Converter", description: "Convert between time zones") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct OvertimeCalculatorView: View {
    var body: some View {
        CalculatorView(title: "Overtime Calculator", description: "Calculate overtime pay") {
            Text("Coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}