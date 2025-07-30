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
                        
                        // Benchmark Comparison
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Benchmark Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let spyReturn = 10.0 // Historical S&P 500 average
                            let bondReturn = 4.0 // Historical bond average
                            let inflationRate = 3.0 // Average inflation
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your Annualized Return",
                                    value: NumberFormatter.formatPercent(annualizedReturn)
                                )
                                InfoRow(
                                    label: "S&P 500 Historical Avg",
                                    value: NumberFormatter.formatPercent(spyReturn)
                                )
                                InfoRow(
                                    label: "Bond Market Avg",
                                    value: NumberFormatter.formatPercent(bondReturn)
                                )
                                InfoRow(
                                    label: "Inflation Rate",
                                    value: NumberFormatter.formatPercent(inflationRate)
                                )
                            }
                            
                            if annualizedReturn > spyReturn {
                                Text("✓ Outperforming the S&P 500!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            } else if annualizedReturn > inflationRate {
                                Text("✓ Beating inflation")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            } else {
                                Text("⚠️ Not keeping pace with inflation")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Growth Projection
                        if timeInYears > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Future Projections")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                let currentRate = annualizedReturn / 100
                                let projectedValue5 = currentPortfolioValue * pow(1 + currentRate, 5)
                                let projectedValue10 = currentPortfolioValue * pow(1 + currentRate, 10)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "In 5 years (at current rate)",
                                        value: NumberFormatter.formatCurrency(projectedValue5)
                                    )
                                    InfoRow(
                                        label: "In 10 years (at current rate)",
                                        value: NumberFormatter.formatCurrency(projectedValue10)
                                    )
                                }
                                
                                Text("*Projections assume current rate continues")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Investment Tips
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
                                if annualizedReturn < 7 {
                                    Text("• Consider low-cost index funds for better returns")
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
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
    
    var annualSavings: Double {
        budgetAmounts.savings * 12
    }
    
    var needsCategories: [(category: String, suggestedAmount: Double, description: String)] {
        let needsAmount = budgetAmounts.needs
        return [
            ("Housing", needsAmount * 0.60, "Rent/mortgage, utilities, insurance"),
            ("Transportation", needsAmount * 0.20, "Car payment, gas, insurance, maintenance"),
            ("Food/Groceries", needsAmount * 0.15, "Essential groceries and household items"),
            ("Healthcare", needsAmount * 0.05, "Insurance premiums, medications")
        ]
    }
    
    var wantsCategories: [(category: String, suggestedAmount: Double, description: String)] {
        let wantsAmount = budgetAmounts.wants
        return [
            ("Entertainment", wantsAmount * 0.30, "Movies, streaming, hobbies"),
            ("Dining Out", wantsAmount * 0.25, "Restaurants, takeout, coffee"),
            ("Shopping", wantsAmount * 0.25, "Clothes, gadgets, non-essentials"),
            ("Personal Care", wantsAmount * 0.20, "Gym, beauty, personal items")
        ]
    }
    
    var savingsCategories: [(category: String, suggestedAmount: Double, description: String)] {
        let savingsAmount = budgetAmounts.savings
        return [
            ("Emergency Fund", savingsAmount * 0.40, "3-6 months of expenses"),
            ("Retirement", savingsAmount * 0.35, "401(k), IRA contributions"),
            ("Short-term Goals", savingsAmount * 0.15, "Vacation, major purchases"),
            ("Debt Repayment", savingsAmount * 0.10, "Extra payments on loans")
        ]
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
                        
                        // Needs Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.red)
                                Text("Needs - \(NumberFormatter.formatCurrency(budgetAmounts.needs))")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 6) {
                                ForEach(needsCategories, id: \.category) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.category)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(NumberFormatter.formatCurrency(item.suggestedAmount))
                                                .font(.subheadline)
                                        }
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemRed).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Wants Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.orange)
                                Text("Wants - \(NumberFormatter.formatCurrency(budgetAmounts.wants))")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 6) {
                                ForEach(wantsCategories, id: \.category) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.category)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(NumberFormatter.formatCurrency(item.suggestedAmount))
                                                .font(.subheadline)
                                        }
                                        Text(item.description)
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
                        
                        // Savings Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("Savings - \(NumberFormatter.formatCurrency(budgetAmounts.savings))")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 6) {
                                ForEach(savingsCategories, id: \.category) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.category)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(NumberFormatter.formatCurrency(item.suggestedAmount))
                                                .font(.subheadline)
                                        }
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            Text("Annual savings: \(NumberFormatter.formatCurrency(annualSavings))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
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
                                Text("• Use the envelope method for discretionary spending")
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
    
    var totalInflation: Double {
        guard let rate = Double(inflationRate),
              let years = Double(timeYears) else { return 0 }
        return (pow(1 + rate/100, years) - 1) * 100
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
}

// Travel Placeholders
struct MPGCalculatorView: View {
    @State private var milesDriven = ""
    @State private var gallonsUsed = ""
    @State private var fuelCost = ""
    @State private var showResults = false
    
    var mpg: Double {
        guard let miles = Double(milesDriven),
              let gallons = Double(gallonsUsed),
              miles > 0, gallons > 0 else { return 0 }
        
        return miles / gallons
    }
    
    var costPerMile: Double {
        guard let cost = Double(fuelCost),
              let miles = Double(milesDriven),
              miles > 0, cost > 0 else { return 0 }
        
        return cost / miles
    }
    
    var costPerGallon: Double {
        guard let cost = Double(fuelCost),
              let gallons = Double(gallonsUsed),
              gallons > 0, cost > 0 else { return 0 }
        
        return cost / gallons
    }
    
    var efficiencyRating: (rating: String, color: Color, description: String) {
        switch mpg {
        case 0..<15:
            return ("Poor", .red, "Consider a more fuel-efficient vehicle")
        case 15..<25:
            return ("Below Average", .orange, "Room for improvement")
        case 25..<35:
            return ("Good", .yellow, "Above average fuel efficiency")
        case 35..<45:
            return ("Excellent", .green, "Very fuel efficient")
        default:
            return ("Outstanding", .blue, "Exceptional fuel efficiency")
        }
    }
    
    var body: some View {
        CalculatorView(title: "Miles Per Gallon", description: "Track fuel efficiency") {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Miles Driven",
                    value: $milesDriven,
                    placeholder: "300",
                    suffix: "miles"
                )
                
                CalculatorInputField(
                    title: "Gallons Used",
                    value: $gallonsUsed,
                    placeholder: "12",
                    suffix: "gallons"
                )
                
                CalculatorInputField(
                    title: "Total Fuel Cost (Optional)",
                    value: $fuelCost,
                    placeholder: "45.00",
                    suffix: "$"
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate MPG") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && mpg > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Fuel Efficiency Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main MPG Result
                        CalculatorResultCard(
                            title: "Miles Per Gallon",
                            value: String(format: "%.1f MPG", mpg),
                            subtitle: efficiencyRating.rating,
                            color: efficiencyRating.color
                        )
                        
                        // Efficiency Rating
                        HStack {
                            Image(systemName: "gauge.medium")
                                .foregroundColor(efficiencyRating.color)
                            Text(efficiencyRating.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(efficiencyRating.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Cost Analysis (if fuel cost is provided)
                        if !fuelCost.isEmpty && costPerMile > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cost Analysis")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Cost per Mile",
                                        value: NumberFormatter.formatCurrency(costPerMile),
                                        color: .orange
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Cost per Gallon",
                                        value: NumberFormatter.formatCurrency(costPerGallon),
                                        color: .purple
                                    )
                                }
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Total Distance",
                                        value: "\(milesDriven) miles"
                                    )
                                    InfoRow(
                                        label: "Total Fuel Used",
                                        value: "\(gallonsUsed) gallons"
                                    )
                                    InfoRow(
                                        label: "Total Fuel Cost",
                                        value: NumberFormatter.formatCurrency(Double(fuelCost) ?? 0)
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Comparison with national average
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let nationalAverage = 25.0
                            let comparison = mpg - nationalAverage
                            let isAboveAverage = comparison > 0
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your MPG",
                                    value: String(format: "%.1f MPG", mpg)
                                )
                                InfoRow(
                                    label: "National Average",
                                    value: String(format: "%.1f MPG", nationalAverage)
                                )
                                InfoRow(
                                    label: "Difference",
                                    value: String(format: "%@%.1f MPG", isAboveAverage ? "+" : "", comparison)
                                )
                            }
                            
                            HStack {
                                Image(systemName: isAboveAverage ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(isAboveAverage ? .green : .red)
                                Text(isAboveAverage ? 
                                     "Above national average! Great fuel efficiency." :
                                     "Below national average. Consider fuel-saving driving habits.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct TripTimeView: View {
    @State private var distance = ""
    @State private var speed = ""
    @State private var stops = ""
    @State private var stopDuration = "15"
    @State private var unitSystem = UnitSystem.miles
    @State private var showResults = false
    
    enum UnitSystem: String, CaseIterable {
        case miles = "Miles/MPH"
        case kilometers = "Kilometers/KPH"
    }
    
    var travelTimeHours: Double {
        guard let dist = Double(distance),
              let spd = Double(speed),
              dist > 0, spd > 0 else { return 0 }
        
        return dist / spd
    }
    
    var stopTimeHours: Double {
        guard let numStops = Double(stops),
              let duration = Double(stopDuration),
              numStops >= 0, duration >= 0 else { return 0 }
        
        return (numStops * duration) / 60.0
    }
    
    var totalTimeHours: Double {
        travelTimeHours + stopTimeHours
    }
    
    var formattedTime: (hours: Int, minutes: Int) {
        let totalMinutes = Int(totalTimeHours * 60)
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    var formattedTravelTime: (hours: Int, minutes: Int) {
        let totalMinutes = Int(travelTimeHours * 60)
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    var arrivalTime: Date {
        Calendar.current.date(byAdding: .minute, value: Int(totalTimeHours * 60), to: Date()) ?? Date()
    }
    
    var fuelEstimate: Double {
        guard let dist = Double(distance) else { return 0 }
        let avgMPG = unitSystem == .miles ? 25.0 : 10.0 // 25 MPG or 10 KM/L
        return dist / avgMPG
    }
    
    var body: some View {
        CalculatorView(title: "Trip Time", description: "Estimate travel duration") {
            VStack(spacing: 20) {
                // Unit System Selection
                SegmentedPicker(
                    title: "Unit System",
                    selection: $unitSystem,
                    options: UnitSystem.allCases.map { ($0, $0.rawValue) }
                )
                
                // Input Fields
                CalculatorInputField(
                    title: "Distance",
                    value: $distance,
                    placeholder: "250",
                    suffix: unitSystem == .miles ? "miles" : "km"
                )
                
                CalculatorInputField(
                    title: "Average Speed",
                    value: $speed,
                    placeholder: "65",
                    suffix: unitSystem == .miles ? "mph" : "km/h"
                )
                
                CalculatorInputField(
                    title: "Number of Stops",
                    value: $stops,
                    placeholder: "2",
                    keyboardType: .numberPad,
                    suffix: "stops"
                )
                
                CalculatorInputField(
                    title: "Stop Duration",
                    value: $stopDuration,
                    placeholder: "15",
                    keyboardType: .numberPad,
                    suffix: "minutes each"
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Trip Time") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalTimeHours > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Trip Duration")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Trip Time",
                            value: "\(formattedTime.hours)h \(formattedTime.minutes)m",
                            subtitle: String(format: "%.1f hours", totalTimeHours),
                            color: .blue
                        )
                        
                        // Time Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Driving Time",
                                    value: "\(formattedTravelTime.hours)h \(formattedTravelTime.minutes)m"
                                )
                                
                                if stopTimeHours > 0 {
                                    InfoRow(
                                        label: "Stop Time",
                                        value: "\(Int(stopTimeHours * 60)) minutes"
                                    )
                                }
                                
                                InfoRow(
                                    label: "Distance",
                                    value: "\(distance) \(unitSystem == .miles ? "miles" : "km")"
                                )
                                
                                InfoRow(
                                    label: "Average Speed",
                                    value: "\(speed) \(unitSystem == .miles ? "mph" : "km/h")"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Arrival Time
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Departure & Arrival")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "If leaving now",
                                    value: DateFormatter.timeFormatter.string(from: Date())
                                )
                                InfoRow(
                                    label: "Estimated arrival",
                                    value: DateFormatter.timeFormatter.string(from: arrivalTime)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Additional Info
                        if unitSystem == .miles {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fuel Estimate")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Estimated fuel needed",
                                        value: String(format: "%.1f gallons", fuelEstimate)
                                    )
                                    InfoRow(
                                        label: "At $3.50/gallon",
                                        value: NumberFormatter.formatCurrency(fuelEstimate * 3.50)
                                    )
                                }
                                
                                Text("*Based on 25 MPG average")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemOrange).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Travel Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Add 10-15% extra time for unexpected delays")
                                Text("• Check traffic conditions before departure")
                                Text("• Plan rest stops every 2 hours for safety")
                                if totalTimeHours > 4 {
                                    Text("• Consider breaking up long trips")
                                }
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

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// Health Placeholders
struct CalorieBurnView: View {
    @State private var weight = ""
    @State private var duration = ""
    @State private var selectedActivity = Activity.running
    @State private var intensity = Intensity.moderate
    @State private var showResults = false
    
    enum Activity: String, CaseIterable {
        case running = "Running"
        case walking = "Walking"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case weightLifting = "Weight Lifting"
        case yoga = "Yoga"
        case dancing = "Dancing"
        case hiking = "Hiking"
        case basketball = "Basketball"
        case tennis = "Tennis"
        
        var baseMET: Double {
            switch self {
            case .running: return 8.0
            case .walking: return 3.8
            case .cycling: return 6.8
            case .swimming: return 8.3
            case .weightLifting: return 6.0
            case .yoga: return 2.5
            case .dancing: return 4.8
            case .hiking: return 6.0
            case .basketball: return 8.0
            case .tennis: return 7.3
            }
        }
    }
    
    enum Intensity: String, CaseIterable {
        case light = "Light"
        case moderate = "Moderate"
        case vigorous = "Vigorous"
        
        var multiplier: Double {
            switch self {
            case .light: return 0.8
            case .moderate: return 1.0
            case .vigorous: return 1.3
            }
        }
    }
    
    var caloriesBurned: Double {
        guard let bodyWeight = Double(weight),
              let exerciseDuration = Double(duration),
              bodyWeight > 0, exerciseDuration > 0 else { return 0 }
        
        let met = selectedActivity.baseMET * intensity.multiplier
        let weightInKg = bodyWeight * 0.453592 // Convert lbs to kg
        
        // Calories = MET × weight(kg) × time(hours)
        return met * weightInKg * (exerciseDuration / 60.0)
    }
    
    var caloriesPerMinute: Double {
        guard let exerciseDuration = Double(duration), exerciseDuration > 0 else { return 0 }
        return caloriesBurned / exerciseDuration
    }
    
    var equivalentFoods: [(food: String, amount: String)] {
        let calories = caloriesBurned
        return [
            ("Apples", "\(Int(calories / 95)) medium apples"),
            ("Bananas", "\(Int(calories / 105)) bananas"),
            ("Slices of bread", "\(Int(calories / 80)) slices"),
            ("Cookies", "\(Int(calories / 150)) chocolate chip cookies"),
            ("Pizza slices", "\(Int(calories / 285)) slices")
        ]
    }
    
    var body: some View {
        CalculatorView(title: "Calorie Burning", description: "Exercise calorie calculator") {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Body Weight",
                    value: $weight,
                    placeholder: "150",
                    suffix: "lbs"
                )
                
                CalculatorInputField(
                    title: "Exercise Duration",
                    value: $duration,
                    placeholder: "30",
                    keyboardType: .numberPad,
                    suffix: "minutes"
                )
                
                // Activity Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Activity", selection: $selectedActivity) {
                        ForEach(Activity.allCases, id: \.self) { activity in
                            Text(activity.rawValue).tag(activity)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Intensity Selection
                SegmentedPicker(
                    title: "Intensity",
                    selection: $intensity,
                    options: Intensity.allCases.map { ($0, $0.rawValue) }
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Calories") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && caloriesBurned > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Calories Burned")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Calories Burned",
                            value: "\(Int(caloriesBurned)) cal",
                            subtitle: "\(selectedActivity.rawValue), \(intensity.rawValue) intensity",
                            color: .orange
                        )
                        
                        // Exercise Details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Calories per minute",
                                    value: String(format: "%.1f cal/min", caloriesPerMinute)
                                )
                                InfoRow(
                                    label: "Activity",
                                    value: "\(selectedActivity.rawValue) (\(intensity.rawValue))"
                                )
                                InfoRow(
                                    label: "Duration",
                                    value: "\(duration) minutes"
                                )
                                InfoRow(
                                    label: "Body Weight",
                                    value: "\(weight) lbs"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Food Equivalents
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Food Equivalents")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("You burned the equivalent of:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 6) {
                                ForEach(equivalentFoods.prefix(3), id: \.food) { food in
                                    InfoRow(
                                        label: food.food,
                                        value: food.amount
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Weekly Goal Context
                        if caloriesBurned > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "target")
                                        .foregroundColor(.blue)
                                    Text("Weekly Goal Progress")
                                        .font(.headline)
                                }
                                
                                let weeklyGoal = 2000.0 // Average weekly calorie burn goal
                                let progressPercent = min((caloriesBurned / weeklyGoal) * 100, 100)
                                
                                VStack(spacing: 4) {
                                    HStack {
                                        Text("Progress toward 2000 cal/week")
                                            .font(.caption)
                                        Spacer()
                                        Text(String(format: "%.1f%%", progressPercent))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    ProgressView(value: progressPercent, total: 100)
                                        .progressViewStyle(.linear)
                                        .tint(.blue)
                                }
                                
                                Text("\(Int(weeklyGoal - caloriesBurned)) calories remaining this week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct DrinkingCaloriesView: View {
    @State private var drinkType = DrinkType.beer
    @State private var quantity = "1"
    @State private var alcoholContent = ""
    @State private var servingSize = ""
    @State private var showResults = false
    
    enum DrinkType: String, CaseIterable {
        case beer = "Beer"
        case wine = "Wine"
        case spirits = "Spirits/Liquor"
        case cocktail = "Cocktail"
        case custom = "Custom"
        
        var typicalABV: Double {
            switch self {
            case .beer: return 5.0
            case .wine: return 12.0
            case .spirits: return 40.0
            case .cocktail: return 15.0
            case .custom: return 0.0
            }
        }
        
        var typicalServing: Double { // in ml
            switch self {
            case .beer: return 355
            case .wine: return 148
            case .spirits: return 44
            case .cocktail: return 120
            case .custom: return 0
            }
        }
    }
    
    var abv: Double {
        if let custom = Double(alcoholContent) {
            return custom
        }
        return drinkType.typicalABV
    }
    
    var serving: Double {
        if let custom = Double(servingSize) {
            return custom
        }
        return drinkType.typicalServing
    }
    
    var alcoholGrams: Double {
        let alcoholVolume = serving * (abv / 100)
        return alcoholVolume * 0.789 // Density of alcohol g/ml
    }
    
    var alcoholCalories: Double {
        alcoholGrams * 7 // 7 calories per gram of alcohol
    }
    
    var totalCaloriesPerDrink: Double {
        let baseCalories = alcoholCalories
        let mixerCalories: Double
        
        switch drinkType {
        case .beer: mixerCalories = serving * 0.1 // ~0.1 cal/ml from carbs
        case .wine: mixerCalories = serving * 0.2 // ~0.2 cal/ml from sugars
        case .spirits: mixerCalories = 0 // Pure spirits
        case .cocktail: mixerCalories = 100 // Estimate for mixers
        case .custom: mixerCalories = 0
        }
        
        return baseCalories + mixerCalories
    }
    
    var totalCalories: Double {
        totalCaloriesPerDrink * (Double(quantity) ?? 1)
    }
    
    var equivalentExercise: [(activity: String, time: String)] {
        let calories = totalCalories
        return [
            ("Walking", "\(Int(calories / 4)) minutes"),
            ("Running", "\(Int(calories / 12)) minutes"),
            ("Cycling", "\(Int(calories / 8)) minutes"),
            ("Swimming", "\(Int(calories / 10)) minutes")
        ]
    }
    
    var body: some View {
        CalculatorView(title: "Drinking Calories", description: "Alcohol calorie calculator") {
            VStack(spacing: 20) {
                // Drink Type Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drink Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Drink Type", selection: $drinkType) {
                        ForEach(DrinkType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: drinkType) { _ in
                        // Reset custom values when type changes
                        if drinkType != .custom {
                            alcoholContent = ""
                            servingSize = ""
                        }
                    }
                }
                
                // Quantity
                CalculatorInputField(
                    title: "Number of Drinks",
                    value: $quantity,
                    placeholder: "1",
                    keyboardType: .numberPad,
                    suffix: "drinks"
                )
                
                // Custom fields for custom type or override
                VStack(spacing: 12) {
                    CalculatorInputField(
                        title: "Alcohol Content (\(drinkType == .custom ? "Required" : "Override"))",
                        value: $alcoholContent,
                        placeholder: String(format: "%.1f", drinkType.typicalABV),
                        suffix: "% ABV"
                    )
                    
                    CalculatorInputField(
                        title: "Serving Size (\(drinkType == .custom ? "Required" : "Override"))",
                        value: $servingSize,
                        placeholder: String(format: "%.0f", drinkType.typicalServing),
                        suffix: "ml"
                    )
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Calories") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalCalories > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Calorie Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Calories",
                            value: "\(Int(totalCalories)) cal",
                            subtitle: "\(quantity) \(drinkType.rawValue.lowercased())\(Int(quantity) ?? 1 > 1 ? "s" : "")",
                            color: .orange
                        )
                        
                        // Per Drink Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Per Drink Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Calories from alcohol",
                                    value: "\(Int(alcoholCalories)) cal"
                                )
                                InfoRow(
                                    label: "Calories from other sources",
                                    value: "\(Int(totalCaloriesPerDrink - alcoholCalories)) cal"
                                )
                                InfoRow(
                                    label: "Total per drink",
                                    value: "\(Int(totalCaloriesPerDrink)) cal"
                                )
                                InfoRow(
                                    label: "Alcohol content",
                                    value: "\(String(format: "%.1f", abv))% ABV"
                                )
                                InfoRow(
                                    label: "Serving size",
                                    value: "\(String(format: "%.0f", serving)) ml"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Exercise Equivalent
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise to Burn Off Calories")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(equivalentExercise, id: \.activity) { exercise in
                                    InfoRow(
                                        label: exercise.activity,
                                        value: exercise.time
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Health Context
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Calorie Context")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let dailyCalories = 2000.0
                            let percentage = (totalCalories / dailyCalories) * 100
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Percentage of 2000-cal diet",
                                    value: String(format: "%.1f%%", percentage)
                                )
                                InfoRow(
                                    label: "Grams of pure alcohol",
                                    value: String(format: "%.1f g", alcoholGrams)
                                )
                            }
                            
                            if percentage > 15 {
                                Text("⚠️ These drinks represent a significant portion of daily calories")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fontWeight(.medium)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Health Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Healthy Drinking Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Moderate drinking: 1 drink/day (women), 2 drinks/day (men)")
                                Text("• Alternate alcoholic drinks with water")
                                Text("• Eat before and while drinking to slow absorption")
                                Text("• Choose lower-calorie options like light beer or wine")
                                Text("• Be aware of mixer calories in cocktails")
                                Text("• Never drink and drive")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemRed).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct OneRepMaxView: View {
    @State private var weight = ""
    @State private var reps = ""
    @State private var selectedFormula = Formula.epley
    @State private var showResults = false
    
    enum Formula: String, CaseIterable {
        case epley = "Epley"
        case brzycki = "Brzycki"
        case lander = "Lander"
        case oconner = "O'Conner"
        
        var description: String {
            switch self {
            case .epley: return "Most common formula (1RM = weight × (1 + reps/30))"
            case .brzycki: return "Good for lower rep ranges (1RM = weight × 36/(37-reps))"
            case .lander: return "Conservative estimate (1RM = weight × 100/(101.3-2.67123×reps))"
            case .oconner: return "Alternative formula (1RM = weight × (1 + reps/40))"
            }
        }
    }
    
    var oneRepMax: Double {
        guard let liftedWeight = Double(weight),
              let repetitions = Double(reps),
              liftedWeight > 0, repetitions > 0, repetitions <= 20 else { return 0 }
        
        switch selectedFormula {
        case .epley:
            return liftedWeight * (1 + repetitions / 30)
        case .brzycki:
            return liftedWeight * 36 / (37 - repetitions)
        case .lander:
            return liftedWeight * 100 / (101.3 - 2.67123 * repetitions)
        case .oconner:
            return liftedWeight * (1 + repetitions / 40)
        }
    }
    
    var allFormulas: [(formula: Formula, result: Double)] {
        Formula.allCases.map { formula in
            let tempFormula = selectedFormula
            let result: Double
            
            guard let liftedWeight = Double(weight),
                  let repetitions = Double(reps),
                  liftedWeight > 0, repetitions > 0, repetitions <= 20 else {
                return (formula, 0)
            }
            
            switch formula {
            case .epley:
                result = liftedWeight * (1 + repetitions / 30)
            case .brzycki:
                result = liftedWeight * 36 / (37 - repetitions)
            case .lander:
                result = liftedWeight * 100 / (101.3 - 2.67123 * repetitions)
            case .oconner:
                result = liftedWeight * (1 + repetitions / 40)
            }
            
            return (formula, result)
        }
    }
    
    var percentageTable: [(percentage: Int, weight: Double)] {
        let baseWeight = oneRepMax
        return [95, 90, 85, 80, 75, 70, 65, 60].map { percentage in
            (percentage, baseWeight * Double(percentage) / 100.0)
        }
    }
    
    var repRanges: [(range: String, percentage: String, purpose: String)] {
        return [
            ("1-3 reps", "90-100%", "Maximum Strength"),
            ("4-6 reps", "85-90%", "Strength & Power"),
            ("6-8 reps", "80-85%", "Strength & Size"),
            ("8-12 reps", "70-80%", "Muscle Growth"),
            ("12-15 reps", "65-70%", "Muscular Endurance"),
            ("15+ reps", "<65%", "Endurance & Conditioning")
        ]
    }
    
    var body: some View {
        CalculatorView(title: "One Rep Max", description: "Weight lifting calculator") {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Weight Lifted",
                    value: $weight,
                    placeholder: "225",
                    suffix: "lbs"
                )
                
                CalculatorInputField(
                    title: "Repetitions Completed",
                    value: $reps,
                    placeholder: "8",
                    keyboardType: .numberPad,
                    suffix: "reps"
                )
                
                // Formula Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calculation Formula")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Formula", selection: $selectedFormula) {
                        ForEach(Formula.allCases, id: \.self) { formula in
                            Text(formula.rawValue).tag(formula)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(selectedFormula.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate 1RM") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && oneRepMax > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("One Rep Max Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Estimated 1RM",
                            value: "\(Int(oneRepMax)) lbs",
                            subtitle: "Using \(selectedFormula.rawValue) formula",
                            color: .red
                        )
                        
                        // All Formula Comparison
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Formula Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(allFormulas, id: \.formula) { item in
                                    InfoRow(
                                        label: item.formula.rawValue,
                                        value: "\(Int(item.result)) lbs"
                                    )
                                }
                            }
                            
                            Text("Average: \(Int(allFormulas.map { $0.result }.reduce(0, +) / Double(allFormulas.count))) lbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Training Percentages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Percentages")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                ForEach(percentageTable, id: \.percentage) { item in
                                    InfoRow(
                                        label: "\(item.percentage)%",
                                        value: "\(Int(item.weight)) lbs"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Rep Ranges & Training Goals
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Guidelines")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(repRanges, id: \.range) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.range)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(item.percentage)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(item.purpose)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Safety Warning
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Safety Guidelines")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Always use a spotter when attempting heavy lifts")
                                Text("• Warm up thoroughly before heavy lifting")
                                Text("• These are estimates - actual 1RM may vary")
                                Text("• Don't attempt 1RM frequently - reserve for testing")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct PregnancyCalculatorView: View {
    @State private var lastPeriodDate = Date()
    @State private var cycleLength = "28"
    @State private var showResults = false
    
    var estimatedDueDate: Date {
        // Add 280 days (40 weeks) to last menstrual period
        Calendar.current.date(byAdding: .day, value: 280, to: lastPeriodDate) ?? Date()
    }
    
    var conceptionDate: Date {
        // Typically 14 days after last period (for 28-day cycle)
        let ovulationDay = (Double(cycleLength) ?? 28) / 2
        return Calendar.current.date(byAdding: .day, value: Int(ovulationDay), to: lastPeriodDate) ?? Date()
    }
    
    var currentWeek: Int {
        let daysSinceLastPeriod = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        return daysSinceLastPeriod / 7
    }
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: estimatedDueDate).day ?? 0
    }
    
    var trimester: (number: Int, description: String) {
        let week = currentWeek
        if week <= 12 {
            return (1, "First Trimester - Development of major organs")
        } else if week <= 27 {
            return (2, "Second Trimester - Often called the 'golden period'")
        } else {
            return (3, "Third Trimester - Final growth and preparation for birth")
        }
    }
    
    var body: some View {
        CalculatorView(title: "Pregnancy Due Date", description: "Calculate estimated due date") {
            VStack(spacing: 20) {
                // Last Period Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Day of Last Menstrual Period")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "Last Period Date",
                        selection: $lastPeriodDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Cycle Length
                CalculatorInputField(
                    title: "Average Cycle Length",
                    value: $cycleLength,
                    placeholder: "28",
                    keyboardType: .numberPad,
                    suffix: "days"
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate Due Date") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Pregnancy Timeline")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Due Date
                        CalculatorResultCard(
                            title: "Estimated Due Date",
                            value: DateFormatter.longDateFormatter.string(from: estimatedDueDate),
                            subtitle: DateFormatter.relativeDateFormatter.localizedString(for: estimatedDueDate, relativeTo: Date()),
                            color: .pink
                        )
                        
                        // Current Status
                        if daysRemaining > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Current Status")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Weeks pregnant",
                                        value: "\(currentWeek) weeks"
                                    )
                                    InfoRow(
                                        label: "Current trimester",
                                        value: "\(trimester.number)"
                                    )
                                    InfoRow(
                                        label: "Days until due date",
                                        value: "\(daysRemaining) days"
                                    )
                                    InfoRow(
                                        label: "Weeks remaining",
                                        value: "\(daysRemaining / 7) weeks"
                                    )
                                }
                                
                                Text(trimester.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color(.systemPink).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Important Dates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Important Dates")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Last menstrual period",
                                    value: DateFormatter.mediumDateFormatter.string(from: lastPeriodDate)
                                )
                                InfoRow(
                                    label: "Estimated conception",
                                    value: DateFormatter.mediumDateFormatter.string(from: conceptionDate)
                                )
                                InfoRow(
                                    label: "End of 1st trimester",
                                    value: DateFormatter.mediumDateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 84, to: lastPeriodDate) ?? Date())
                                )
                                InfoRow(
                                    label: "End of 2nd trimester",
                                    value: DateFormatter.mediumDateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 189, to: lastPeriodDate) ?? Date())
                                )
                                InfoRow(
                                    label: "Due date",
                                    value: DateFormatter.mediumDateFormatter.string(from: estimatedDueDate)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Milestone Schedule
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Typical Milestones by Week")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let milestones = [
                                ("Week 8", "First prenatal appointment"),
                                ("Week 12", "End of first trimester, nuchal translucency scan"),
                                ("Week 16", "Possible gender determination"),
                                ("Week 20", "Anatomy scan, halfway point"),
                                ("Week 24", "Glucose screening test"),
                                ("Week 28", "Start of third trimester"),
                                ("Week 36", "Baby considered full-term soon"),
                                ("Week 40", "Due date - baby is full-term")
                            ]
                            
                            VStack(spacing: 6) {
                                ForEach(milestones, id: \.0) { milestone in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(milestone.0)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                        }
                                        Text(milestone.1)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Important Note
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Important Information")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• This is an estimation based on a 280-day pregnancy")
                                Text("• Only about 5% of babies are born on their due date")
                                Text("• Full-term is considered 37-42 weeks")
                                Text("• Consult healthcare providers for personalized care")
                                Text("• Due dates may be adjusted after ultrasound scans")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// Utilities Placeholders
struct PhoneCostView: View {
    @State private var monthlyBill = ""
    @State private var minutesUsed = ""
    @State private var dataUsed = ""
    @State private var textsSent = ""
    @State private var planType = PlanType.unlimited
    @State private var showResults = false
    
    enum PlanType: String, CaseIterable {
        case unlimited = "Unlimited"
        case limited = "Limited Minutes"
        case payPerUse = "Pay Per Use"
        
        var description: String {
            switch self {
            case .unlimited: return "Unlimited talk, text, and data"
            case .limited: return "Fixed number of minutes included"
            case .payPerUse: return "Pay for each minute/text/MB used"
            }
        }
    }
    
    var totalBill: Double {
        Double(monthlyBill) ?? 0
    }
    
    var totalMinutes: Double {
        Double(minutesUsed) ?? 0
    }
    
    var totalData: Double {
        Double(dataUsed) ?? 0
    }
    
    var totalTexts: Double {
        Double(textsSent) ?? 0
    }
    
    var costPerMinute: Double {
        guard totalMinutes > 0, totalBill > 0 else { return 0 }
        return totalBill / totalMinutes
    }
    
    var costPerText: Double {
        guard totalTexts > 0, totalBill > 0 else { return 0 }
        return totalBill / totalTexts
    }
    
    var costPerGB: Double {
        guard totalData > 0, totalBill > 0 else { return 0 }
        return totalBill / totalData
    }
    
    var dailyCost: Double {
        totalBill / 30 // Approximate days in month
    }
    
    var costPerHour: Double {
        totalBill / (30 * 24) // Cost per hour of the month
    }
    
    var usageBreakdown: [(category: String, usage: String, estimatedCost: Double)] {
        let voiceCost = totalBill * 0.4 // Assume 40% of bill is voice
        let dataCost = totalBill * 0.5  // Assume 50% of bill is data
        let textCost = totalBill * 0.1  // Assume 10% of bill is text
        
        return [
            ("Voice Calls", "\(Int(totalMinutes)) minutes", voiceCost),
            ("Data Usage", "\(String(format: "%.1f", totalData)) GB", dataCost),
            ("Text Messages", "\(Int(totalTexts)) texts", textCost)
        ]
    }
    
    var efficiencyRating: (rating: String, color: Color, suggestion: String) {
        if costPerMinute == 0 {
            return ("No Usage Data", .gray, "Enter your usage to see efficiency")
        } else if costPerMinute < 0.10 {
            return ("Excellent Value", .green, "Great deal! You're using your plan efficiently")
        } else if costPerMinute < 0.25 {
            return ("Good Value", .blue, "Reasonable cost per minute")
        } else if costPerMinute < 0.50 {
            return ("Fair Value", .orange, "Consider a different plan if usage increases")
        } else {
            return ("Poor Value", .red, "You might benefit from an unlimited plan")
        }
    }
    
    var body: some View {
        CalculatorView(title: "Phone Cost Per Minute", description: "Calculate phone usage costs") {
            VStack(spacing: 20) {
                // Plan Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plan Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Plan Type", selection: $planType) {
                        ForEach(PlanType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(planType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Input Fields
                CalculatorInputField(
                    title: "Monthly Phone Bill",
                    value: $monthlyBill,
                    placeholder: "85.00",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Minutes Used",
                    value: $minutesUsed,
                    placeholder: "450",
                    keyboardType: .numberPad,
                    suffix: "minutes"
                )
                
                CalculatorInputField(
                    title: "Data Used",
                    value: $dataUsed,
                    placeholder: "8.5",
                    suffix: "GB"
                )
                
                CalculatorInputField(
                    title: "Text Messages Sent",
                    value: $textsSent,
                    placeholder: "300",
                    keyboardType: .numberPad,
                    suffix: "texts"
                )
                
                // Calculate Button
                CalculatorButton(title: "Analyze Phone Costs") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalBill > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Phone Cost Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Efficiency Rating
                        CalculatorResultCard(
                            title: "Plan Efficiency",
                            value: efficiencyRating.rating,
                            subtitle: efficiencyRating.suggestion,
                            color: efficiencyRating.color
                        )
                        
                        // Cost Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cost Per Unit")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                if totalMinutes > 0 {
                                    InfoRow(
                                        label: "Cost per minute",
                                        value: NumberFormatter.formatCurrency(costPerMinute)
                                    )
                                }
                                if totalTexts > 0 {
                                    InfoRow(
                                        label: "Cost per text",
                                        value: NumberFormatter.formatCurrency(costPerText)
                                    )
                                }
                                if totalData > 0 {
                                    InfoRow(
                                        label: "Cost per GB",
                                        value: NumberFormatter.formatCurrency(costPerGB)
                                    )
                                }
                                InfoRow(
                                    label: "Daily cost",
                                    value: NumberFormatter.formatCurrency(dailyCost)
                                )
                                InfoRow(
                                    label: "Hourly cost",
                                    value: NumberFormatter.formatCurrency(costPerHour)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Usage Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Monthly Usage Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Total bill",
                                    value: NumberFormatter.formatCurrency(totalBill)
                                )
                                if totalMinutes > 0 {
                                    InfoRow(
                                        label: "Talk time",
                                        value: "\(String(format: "%.0f", totalMinutes)) min (\(String(format: "%.1f", totalMinutes/60)) hours)"
                                    )
                                }
                                if totalData > 0 {
                                    InfoRow(
                                        label: "Data usage",
                                        value: "\(String(format: "%.1f", totalData)) GB (\(String(format: "%.0f", totalData * 1024)) MB)"
                                    )
                                }
                                if totalTexts > 0 {
                                    InfoRow(
                                        label: "Text messages",
                                        value: "\(String(format: "%.0f", totalTexts)) texts"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Cost Distribution (estimated)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Estimated Cost Distribution")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(usageBreakdown, id: \.category) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.category)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(item.usage)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(NumberFormatter.formatCurrency(item.estimatedCost))
                                            .fontWeight(.medium)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            Text("*Estimates based on typical plan allocations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Comparison with averages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("National Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let avgMonthlyBill = 80.0
                            let avgMinutesUsed = 400.0
                            let avgDataUsed = 7.0
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your monthly bill",
                                    value: NumberFormatter.formatCurrency(totalBill)
                                )
                                InfoRow(
                                    label: "National average",
                                    value: NumberFormatter.formatCurrency(avgMonthlyBill)
                                )
                                InfoRow(
                                    label: "Difference",
                                    value: "\(totalBill > avgMonthlyBill ? "+" : "")\(NumberFormatter.formatCurrency(totalBill - avgMonthlyBill))"
                                )
                            }
                            
                            let comparison = totalBill < avgMonthlyBill ? "below" : "above"
                            Text("Your bill is \(comparison) the national average")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Money-saving tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("Money-Saving Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Use Wi-Fi when available to reduce data usage")
                                Text("• Monitor usage with your carrier's app")
                                Text("• Consider family plans if you have multiple lines")
                                Text("• Look into prepaid plans for predictable costs")
                                Text("• Review and remove unused features monthly")
                                if costPerMinute > 0.25 {
                                    Text("• Consider switching to an unlimited plan")
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct MonthlyBillsView: View {
    @State private var bills: [BillItem] = [BillItem()]
    @State private var showResults = false
    
    struct BillItem: Identifiable {
        let id = UUID()
        var name = ""
        var amount = ""
        var category = BillCategory.utilities
        var frequency = BillFrequency.monthly
    }
    
    enum BillCategory: String, CaseIterable {
        case utilities = "Utilities"
        case housing = "Housing"
        case transportation = "Transportation"
        case insurance = "Insurance"
        case subscriptions = "Subscriptions"
        case debt = "Debt Payments"
        case other = "Other"
        
        var color: Color {
            switch self {
            case .utilities: return .yellow
            case .housing: return .blue
            case .transportation: return .green
            case .insurance: return .purple
            case .subscriptions: return .orange
            case .debt: return .red
            case .other: return .gray
            }
        }
    }
    
    enum BillFrequency: String, CaseIterable {
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case annually = "Annually"
        
        var monthlyMultiplier: Double {
            switch self {
            case .weekly: return 4.33
            case .biweekly: return 2.17
            case .monthly: return 1.0
            case .quarterly: return 1.0 / 3.0
            case .annually: return 1.0 / 12.0
            }
        }
    }
    
    var totalMonthlyBills: Double {
        bills.compactMap { bill in
            guard let amount = Double(bill.amount), !bill.name.isEmpty else { return nil }
            return amount * bill.frequency.monthlyMultiplier
        }.reduce(0, +)
    }
    
    var billsByCategory: [(category: BillCategory, total: Double)] {
        BillCategory.allCases.map { category in
            let total = bills
                .filter { $0.category == category && !$0.amount.isEmpty && !$0.name.isEmpty }
                .compactMap { Double($0.amount) }
                .enumerated()
                .map { index, amount in
                    let bill = bills.filter { $0.category == category }[index]
                    return amount * bill.frequency.monthlyMultiplier
                }
                .reduce(0, +)
            return (category, total)
        }.filter { $0.total > 0 }
    }
    
    var body: some View {
        CalculatorView(title: "Monthly Bills", description: "Track recurring expenses") {
            VStack(spacing: 20) {
                // Bills Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bills")
                            .font(.headline)
                        Spacer()
                        Button("Add Bill") {
                            bills.append(BillItem())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(bills.indices, id: \.self) { index in
                        BillRowView(
                            bill: $bills[index],
                            onDelete: {
                                if bills.count > 1 {
                                    bills.remove(at: index)
                                }
                            }
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Monthly Total") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalMonthlyBills > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Monthly Bills Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Total Monthly Bills
                        CalculatorResultCard(
                            title: "Total Monthly Bills",
                            value: NumberFormatter.formatCurrency(totalMonthlyBills),
                            color: .red
                        )
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("By Category")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(billsByCategory, id: \.category) { item in
                                    HStack {
                                        Circle()
                                            .fill(item.category.color)
                                            .frame(width: 12, height: 12)
                                        Text(item.category.rawValue)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(NumberFormatter.formatCurrency(item.total))
                                            .fontWeight(.medium)
                                        Text(String(format: "%.1f%%", (item.total / totalMonthlyBills) * 100))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Annual Impact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Annual Impact")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let annualTotal = totalMonthlyBills * 12
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Annual bills total",
                                    value: NumberFormatter.formatCurrency(annualTotal)
                                )
                                InfoRow(
                                    label: "Daily average",
                                    value: NumberFormatter.formatCurrency(totalMonthlyBills / 30)
                                )
                                InfoRow(
                                    label: "Weekly average",
                                    value: NumberFormatter.formatCurrency(totalMonthlyBills / 4.33)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Income Context
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Income Guidelines")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let recommendedIncome = totalMonthlyBills / 0.5 // Bills should be ~50% of income
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Recommended monthly income",
                                    value: NumberFormatter.formatCurrency(recommendedIncome)
                                )
                                InfoRow(
                                    label: "If 50% of income rule",
                                    value: "Bills = 50% of take-home pay"
                                )
                            }
                            
                            Text("Bills typically shouldn't exceed 50% of take-home pay")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Money-Saving Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("Money-Saving Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Review and cancel unused subscriptions")
                                Text("• Bundle services (internet, phone, insurance)")
                                Text("• Set up autopay for discounts")
                                Text("• Compare providers annually")
                                Text("• Negotiate bills (insurance, phone, internet)")
                                Text("• Consider energy-efficient appliances")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct BillRowView: View {
    @Binding var bill: MonthlyBillsView.BillItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Bill Name", text: $bill.name)
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
                    
                    Picker("Category", selection: $bill.category) {
                        ForEach(MonthlyBillsView.BillCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("$0", text: $bill.amount)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frequency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Frequency", selection: $bill.frequency) {
                        ForEach(MonthlyBillsView.BillFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RentingCostView: View {
    @State private var monthlyRent = ""
    @State private var securityDeposit = ""
    @State private var utilities = ""
    @State private var parking = ""
    @State private var insurance = ""
    @State private var otherFees = ""
    @State private var leaseLength = "12"
    @State private var showResults = false
    
    var totalMonthlyCost: Double {
        let costs = [
            Double(monthlyRent) ?? 0,
            Double(utilities) ?? 0,
            Double(parking) ?? 0,
            Double(insurance) ?? 0,
            Double(otherFees) ?? 0
        ]
        return costs.reduce(0, +)
    }
    
    var totalLeaseCost: Double {
        let months = Double(leaseLength) ?? 12
        let deposit = Double(securityDeposit) ?? 0
        return (totalMonthlyCost * months) + deposit
    }
    
    var dailyCost: Double {
        totalMonthlyCost / 30
    }
    
    var costBreakdown: [(category: String, amount: Double, percentage: Double)] {
        let items = [
            ("Base Rent", Double(monthlyRent) ?? 0),
            ("Utilities", Double(utilities) ?? 0),
            ("Parking", Double(parking) ?? 0),
            ("Insurance", Double(insurance) ?? 0),
            ("Other Fees", Double(otherFees) ?? 0)
        ]
        
        return items.map { (category, amount) in
            let percentage = totalMonthlyCost > 0 ? (amount / totalMonthlyCost) * 100 : 0
            return (category, amount, percentage)
        }.filter { $0.amount > 0 }
    }
    
    var body: some View {
        CalculatorView(title: "Renting Cost", description: "Calculate true cost of renting") {
            VStack(spacing: 20) {
                // Basic Rent
                CalculatorInputField(
                    title: "Monthly Rent",
                    value: $monthlyRent,
                    placeholder: "1500",
                    suffix: "$"
                )
                
                // Security Deposit
                CalculatorInputField(
                    title: "Security Deposit",
                    value: $securityDeposit,
                    placeholder: "1500",
                    suffix: "$"
                )
                
                // Additional Monthly Costs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Additional Monthly Costs")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Utilities (Electric, Gas, Water)",
                            value: $utilities,
                            placeholder: "150",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Parking",
                            value: $parking,
                            placeholder: "50",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Renter's Insurance",
                            value: $insurance,
                            placeholder: "25",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Other Fees (Pet, Amenities, etc.)",
                            value: $otherFees,
                            placeholder: "30",
                            suffix: "$"
                        )
                    }
                }
                
                // Lease Length
                CalculatorInputField(
                    title: "Lease Length",
                    value: $leaseLength,
                    placeholder: "12",
                    keyboardType: .numberPad,
                    suffix: "months"
                )
                
                // Calculate Button
                CalculatorButton(title: "Calculate True Cost") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalMonthlyCost > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("True Cost of Renting")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Results
                        VStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "Total Monthly Cost",
                                value: NumberFormatter.formatCurrency(totalMonthlyCost),
                                color: .blue
                            )
                            
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Daily Cost",
                                    value: NumberFormatter.formatCurrency(dailyCost),
                                    color: .orange
                                )
                                
                                CalculatorResultCard(
                                    title: "Total Lease Cost",
                                    value: NumberFormatter.formatCurrency(totalLeaseCost),
                                    subtitle: "\(leaseLength) months + deposit",
                                    color: .purple
                                )
                            }
                        }
                        
                        // Cost Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Monthly Cost Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(costBreakdown, id: \.category) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.category)
                                                .font(.subheadline)
                                            Text(String(format: "%.1f%% of total", item.percentage))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(NumberFormatter.formatCurrency(item.amount))
                                            .fontWeight(.medium)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Annual Costs
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Annual Analysis")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Annual rent payments",
                                    value: NumberFormatter.formatCurrency((Double(monthlyRent) ?? 0) * 12)
                                )
                                InfoRow(
                                    label: "Annual additional costs",
                                    value: NumberFormatter.formatCurrency((totalMonthlyCost - (Double(monthlyRent) ?? 0)) * 12)
                                )
                                InfoRow(
                                    label: "Total annual housing cost",
                                    value: NumberFormatter.formatCurrency(totalMonthlyCost * 12)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Income Guidelines
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Income Guidelines")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let rule30Income = totalMonthlyCost / 0.30
                            let rule25Income = totalMonthlyCost / 0.25
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Recommended income (30% rule)",
                                    value: NumberFormatter.formatCurrency(rule30Income)
                                )
                                InfoRow(
                                    label: "Conservative income (25% rule)",
                                    value: NumberFormatter.formatCurrency(rule25Income)
                                )
                                InfoRow(
                                    label: "Annual income needed (30% rule)",
                                    value: NumberFormatter.formatCurrency(rule30Income * 12)
                                )
                            }
                            
                            Text("Housing costs should typically not exceed 25-30% of gross income")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Rent vs Buy Comparison
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rent vs Buy Context")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let mortgageEquivalent = totalMonthlyCost * 0.8 // Rough estimate
                            let homePrice = mortgageEquivalent * 12 * 20 // Very rough estimate
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Equivalent mortgage payment",
                                    value: "~\(NumberFormatter.formatCurrency(mortgageEquivalent))"
                                )
                                InfoRow(
                                    label: "Rough home price equivalent",
                                    value: "~\(NumberFormatter.formatCurrency(homePrice))"
                                )
                            }
                            
                            Text("*Very rough estimates. Actual home buying involves many factors")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemPurple).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Renting Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(.blue)
                                Text("Renting Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Factor in all costs, not just base rent")
                                Text("• Research neighborhood utility costs")
                                Text("• Understand what's included in rent")
                                Text("• Budget for renter's insurance")
                                Text("• Consider proximity to work (commute costs)")
                                Text("• Negotiate lease terms and fees when possible")
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
        }
    }
}

// Education Placeholders
struct GPACalculatorView: View {
    @State private var courses: [Course] = [Course()]
    @State private var gpaScale = GPAScale.fourPoint
    @State private var showResults = false
    
    enum GPAScale: String, CaseIterable {
        case fourPoint = "4.0 Scale"
        case fivePoint = "5.0 Scale (Weighted)"
        
        var maxValue: Double {
            switch self {
            case .fourPoint: return 4.0
            case .fivePoint: return 5.0
            }
        }
    }
    
    struct Course: Identifiable {
        let id = UUID()
        var name = ""
        var grade = Grade.a
        var creditHours = "3"
        var isHonorsAP = false
    }
    
    enum Grade: String, CaseIterable {
        case aPlus = "A+"
        case a = "A"
        case aMinus = "A-"
        case bPlus = "B+"
        case b = "B"
        case bMinus = "B-"
        case cPlus = "C+"
        case c = "C"
        case cMinus = "C-"
        case dPlus = "D+"
        case d = "D"
        case f = "F"
        
        func gpaValue(scale: GPAScale, isHonorsAP: Bool = false) -> Double {
            let baseValue: Double
            switch self {
            case .aPlus, .a: baseValue = 4.0
            case .aMinus: baseValue = 3.7
            case .bPlus: baseValue = 3.3
            case .b: baseValue = 3.0
            case .bMinus: baseValue = 2.7
            case .cPlus: baseValue = 2.3
            case .c: baseValue = 2.0
            case .cMinus: baseValue = 1.7
            case .dPlus: baseValue = 1.3
            case .d: baseValue = 1.0
            case .f: baseValue = 0.0
            }
            
            if scale == .fivePoint && isHonorsAP && baseValue > 0 {
                return min(baseValue + 1.0, 5.0)
            }
            
            return baseValue
        }
    }
    
    var calculatedGPA: Double {
        let validCourses = courses.filter { !$0.name.isEmpty }
        guard !validCourses.isEmpty else { return 0 }
        
        var totalPoints = 0.0
        var totalCredits = 0.0
        
        for course in validCourses {
            guard let credits = Double(course.creditHours), credits > 0 else { continue }
            let gradePoints = course.grade.gpaValue(scale: gpaScale, isHonorsAP: course.isHonorsAP)
            totalPoints += gradePoints * credits
            totalCredits += credits
        }
        
        return totalCredits > 0 ? totalPoints / totalCredits : 0
    }
    
    var totalCreditHours: Double {
        courses.compactMap { Double($0.creditHours) }.reduce(0, +)
    }
    
    var gpaCategory: (category: String, color: Color, description: String) {
        switch calculatedGPA {
        case 3.8...4.0:
            return ("Summa Cum Laude", .green, "Highest Honors - Excellent academic performance")
        case 3.5..<3.8:
            return ("Magna Cum Laude", .blue, "High Honors - Very good academic performance")
        case 3.2..<3.5:
            return ("Cum Laude", .purple, "Honors - Good academic performance")
        case 3.0..<3.2:
            return ("Good Standing", .orange, "Satisfactory academic performance")
        case 2.0..<3.0:
            return ("Academic Warning", .yellow, "Below average - improvement needed")
        default:
            return ("Academic Probation", .red, "Unsatisfactory - immediate improvement required")
        }
    }
    
    var body: some View {
        CalculatorView(title: "GPA Calculator", description: "Calculate grade point average") {
            VStack(spacing: 20) {
                // GPA Scale Selection
                SegmentedPicker(
                    title: "GPA Scale",
                    selection: $gpaScale,
                    options: GPAScale.allCases.map { ($0, $0.rawValue) }
                )
                
                // Courses Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Courses")
                            .font(.headline)
                        Spacer()
                        Button("Add Course") {
                            courses.append(Course())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(courses.indices, id: \.self) { index in
                        CourseRowView(
                            course: $courses[index],
                            gpaScale: gpaScale,
                            onDelete: {
                                if courses.count > 1 {
                                    courses.remove(at: index)
                                }
                            }
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate GPA") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && calculatedGPA > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("GPA Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main GPA Result
                        CalculatorResultCard(
                            title: "Your GPA",
                            value: String(format: "%.2f", calculatedGPA),
                            subtitle: "\(gpaScale.rawValue) (\(gpaCategory.category))",
                            color: gpaCategory.color
                        )
                        
                        // GPA Category Description
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(gpaCategory.color)
                            Text(gpaCategory.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(gpaCategory.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Academic Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Academic Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Total Credit Hours",
                                    value: String(format: "%.0f", totalCreditHours)
                                )
                                InfoRow(
                                    label: "Number of Courses",
                                    value: "\(courses.filter { !$0.name.isEmpty }.count)"
                                )
                                InfoRow(
                                    label: "GPA Scale",
                                    value: gpaScale.rawValue
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Grade Distribution
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Grade Distribution")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let gradeDistribution = Dictionary(grouping: courses.filter { !$0.name.isEmpty }) { $0.grade }
                            
                            VStack(spacing: 6) {
                                ForEach(Grade.allCases, id: \.self) { grade in
                                    if let coursesWithGrade = gradeDistribution[grade], !coursesWithGrade.isEmpty {
                                        InfoRow(
                                            label: grade.rawValue,
                                            value: "\(coursesWithGrade.count) course\(coursesWithGrade.count > 1 ? "s" : "")"
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct CourseRowView: View {
    @Binding var course: GPACalculatorView.Course
    let gpaScale: GPACalculatorView.GPAScale
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Course Name", text: $course.name)
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
                    Text("Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Grade", selection: $course.grade) {
                        ForEach(GPACalculatorView.Grade.allCases, id: \.self) { grade in
                            Text(grade.rawValue).tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("3", text: $course.creditHours)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                }
                
                if gpaScale == .fivePoint {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Honors/AP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle("", isOn: $course.isHonorsAP)
                            .labelsHidden()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SchoolCostView: View {
    @State private var tuition = ""
    @State private var roomBoard = ""
    @State private var books = ""
    @State private var transportation = ""
    @State private var personal = ""
    @State private var other = ""
    @State private var yearsInSchool = "4"
    @State private var showResults = false
    
    var totalAnnualCost: Double {
        let costs = [
            Double(tuition) ?? 0,
            Double(roomBoard) ?? 0,
            Double(books) ?? 0,
            Double(transportation) ?? 0,
            Double(personal) ?? 0,
            Double(other) ?? 0
        ]
        return costs.reduce(0, +)
    }
    
    var totalDegreeCost: Double {
        guard let years = Double(yearsInSchool), years > 0 else { return totalAnnualCost }
        return totalAnnualCost * years
    }
    
    var monthlyPayment: Double {
        guard let years = Double(yearsInSchool), years > 0 else { return 0 }
        return totalAnnualCost / 12
    }
    
    var costBreakdown: [(category: String, amount: Double, percentage: Double)] {
        let items = [
            ("Tuition & Fees", Double(tuition) ?? 0),
            ("Room & Board", Double(roomBoard) ?? 0),
            ("Books & Supplies", Double(books) ?? 0),
            ("Transportation", Double(transportation) ?? 0),
            ("Personal Expenses", Double(personal) ?? 0),
            ("Other Costs", Double(other) ?? 0)
        ]
        
        return items.map { (category, amount) in
            let percentage = totalAnnualCost > 0 ? (amount / totalAnnualCost) * 100 : 0
            return (category, amount, percentage)
        }.filter { $0.amount > 0 }
    }
    
    var body: some View {
        CalculatorView(title: "School Cost", description: "Calculate education expenses") {
            VStack(spacing: 20) {
                // Duration
                CalculatorInputField(
                    title: "Years in School",
                    value: $yearsInSchool,
                    placeholder: "4",
                    keyboardType: .numberPad,
                    suffix: "years"
                )
                
                // Cost Categories
                VStack(alignment: .leading, spacing: 16) {
                    Text("Annual Expenses")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Tuition & Fees",
                            value: $tuition,
                            placeholder: "25000",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Room & Board",
                            value: $roomBoard,
                            placeholder: "12000",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Books & Supplies",
                            value: $books,
                            placeholder: "1200",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Transportation",
                            value: $transportation,
                            placeholder: "2000",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Personal Expenses",
                            value: $personal,
                            placeholder: "1500",
                            suffix: "$"
                        )
                        
                        CalculatorInputField(
                            title: "Other Costs",
                            value: $other,
                            placeholder: "500",
                            suffix: "$"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate School Costs") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalAnnualCost > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Education Cost Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Results
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Annual Cost",
                                value: NumberFormatter.formatCurrency(totalAnnualCost),
                                color: .blue
                            )
                            
                            CalculatorResultCard(
                                title: "Total Degree Cost",
                                value: NumberFormatter.formatCurrency(totalDegreeCost),
                                subtitle: "\(yearsInSchool) years",
                                color: .purple
                            )
                        }
                        
                        // Monthly Breakdown
                        CalculatorResultCard(
                            title: "Monthly Cost",
                            value: NumberFormatter.formatCurrency(monthlyPayment),
                            subtitle: "Annual cost divided by 12 months",
                            color: .orange
                        )
                        
                        // Cost Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cost Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(costBreakdown, id: \.category) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.category)
                                                .font(.subheadline)
                                            Text(String(format: "%.1f%% of total", item.percentage))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(NumberFormatter.formatCurrency(item.amount))
                                            .fontWeight(.medium)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Financing Options
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Financing Scenarios")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "If paying cash",
                                    value: NumberFormatter.formatCurrency(totalDegreeCost)
                                )
                                InfoRow(
                                    label: "Student loan (6% APR, 10yr)",
                                    value: "~\(NumberFormatter.formatCurrency(calculateMonthlyPayment(principal: totalDegreeCost, rate: 0.06, years: 10)))/month"
                                )
                                InfoRow(
                                    label: "Parent PLUS loan (7% APR, 10yr)",
                                    value: "~\(NumberFormatter.formatCurrency(calculateMonthlyPayment(principal: totalDegreeCost, rate: 0.07, years: 10)))/month"
                                )
                                InfoRow(
                                    label: "529 Plan savings needed",
                                    value: "~\(NumberFormatter.formatCurrency(totalDegreeCost * 0.8)) (80% coverage)"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Comparison with National Averages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("National Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let publicAverage = 22180.0
                            let privateAverage = 50770.0
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your annual cost",
                                    value: NumberFormatter.formatCurrency(totalAnnualCost)
                                )
                                InfoRow(
                                    label: "Public 4-year average",
                                    value: NumberFormatter.formatCurrency(publicAverage)
                                )
                                InfoRow(
                                    label: "Private 4-year average",
                                    value: NumberFormatter.formatCurrency(privateAverage)
                                )
                            }
                            
                            let comparison = totalAnnualCost < publicAverage ? "below public average" : 
                                           totalAnnualCost < privateAverage ? "above public, below private average" : "above average"
                            
                            Text("Your costs are \(comparison)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Tips for Reducing Costs
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Cost-Saving Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Apply for scholarships and grants early")
                                Text("• Consider community college for first 2 years")
                                Text("• Buy used textbooks or rent them")
                                Text("• Live off-campus or commute to save on room & board")
                                Text("• Take AP courses for college credit")
                                Text("• Look into in-state tuition options")
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
    
    private func calculateMonthlyPayment(principal: Double, rate: Double, years: Double) -> Double {
        let monthlyRate = rate / 12
        let numPayments = years * 12
        
        if monthlyRate == 0 {
            return principal / numPayments
        }
        
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, numPayments)) / (pow(1 + monthlyRate, numPayments) - 1)
        return payment
    }
}

// Lifestyle Placeholders
struct TipCalculatorView: View {
    @State private var billAmount = ""
    @State private var tipPercentage = "20"
    @State private var numberOfPeople = "1"
    @State private var showResults = false
    
    var totalTip: Double {
        guard let bill = Double(billAmount),
              let tip = Double(tipPercentage),
              bill > 0, tip >= 0 else { return 0 }
        
        return bill * (tip / 100)
    }
    
    var totalAmount: Double {
        guard let bill = Double(billAmount) else { return 0 }
        return bill + totalTip
    }
    
    var amountPerPerson: Double {
        guard let people = Double(numberOfPeople),
              people > 0 else { return totalAmount }
        
        return totalAmount / people
    }
    
    var tipPerPerson: Double {
        guard let people = Double(numberOfPeople),
              people > 0 else { return totalTip }
        
        return totalTip / people
    }
    
    var body: some View {
        CalculatorView(title: "Tip Calculator", description: "Calculate tips and split bills") {
            VStack(spacing: 20) {
                // Input Fields
                CalculatorInputField(
                    title: "Bill Amount",
                    value: $billAmount,
                    placeholder: "50.00",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Tip Percentage",
                    value: $tipPercentage,
                    placeholder: "20",
                    suffix: "%"
                )
                
                CalculatorInputField(
                    title: "Number of People",
                    value: $numberOfPeople,
                    placeholder: "1",
                    keyboardType: .numberPad,
                    suffix: "people"
                )
                
                // Quick tip percentage buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Tip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(["10", "15", "18", "20", "25"], id: \.self) { percentage in
                            Button(percentage + "%") {
                                tipPercentage = percentage
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(tipPercentage == percentage ? .white : .blue)
                            .background(tipPercentage == percentage ? Color.blue : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Tip") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalAmount > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Tip Amount",
                                value: NumberFormatter.formatCurrency(totalTip),
                                color: .green
                            )
                            
                            CalculatorResultCard(
                                title: "Total Bill",
                                value: NumberFormatter.formatCurrency(totalAmount),
                                color: .blue
                            )
                        }
                        
                        if let people = Double(numberOfPeople), people > 1 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Per Person Breakdown")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Amount per person",
                                        value: NumberFormatter.formatCurrency(amountPerPerson)
                                    )
                                    InfoRow(
                                        label: "Tip per person",
                                        value: NumberFormatter.formatCurrency(tipPerPerson)
                                    )
                                    InfoRow(
                                        label: "Bill per person",
                                        value: NumberFormatter.formatCurrency((Double(billAmount) ?? 0) / people)
                                    )
                                }
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
}

struct UnitConverterView: View {
    @State private var inputValue = ""
    @State private var selectedCategory = ConversionCategory.length
    @State private var fromUnit = 0
    @State private var toUnit = 1
    @State private var showResults = false
    
    enum ConversionCategory: String, CaseIterable {
        case length = "Length"
        case weight = "Weight"
        case temperature = "Temperature"
        case volume = "Volume"
        case area = "Area"
        case speed = "Speed"
        
        var units: [String] {
            switch self {
            case .length:
                return ["Millimeter", "Centimeter", "Meter", "Kilometer", "Inch", "Foot", "Yard", "Mile"]
            case .weight:
                return ["Gram", "Kilogram", "Ounce", "Pound", "Stone", "Ton (Metric)", "Ton (US)"]
            case .temperature:
                return ["Celsius", "Fahrenheit", "Kelvin"]
            case .volume:
                return ["Milliliter", "Liter", "Fluid Ounce", "Cup", "Pint", "Quart", "Gallon"]
            case .area:
                return ["Square Meter", "Square Kilometer", "Square Foot", "Square Yard", "Acre", "Hectare"]
            case .speed:
                return ["Meter/Second", "Kilometer/Hour", "Mile/Hour", "Knot", "Foot/Second"]
            }
        }
        
        var abbreviations: [String] {
            switch self {
            case .length:
                return ["mm", "cm", "m", "km", "in", "ft", "yd", "mi"]
            case .weight:
                return ["g", "kg", "oz", "lb", "st", "t", "ton"]
            case .temperature:
                return ["°C", "°F", "K"]
            case .volume:
                return ["ml", "L", "fl oz", "cup", "pt", "qt", "gal"]
            case .area:
                return ["m²", "km²", "ft²", "yd²", "acre", "ha"]
            case .speed:
                return ["m/s", "km/h", "mph", "kn", "ft/s"]
            }
        }
    }
    
    var convertedValue: Double {
        guard let input = Double(inputValue), input >= 0 else { return 0 }
        
        // Convert to base unit first, then to target unit
        let baseValue = convertToBase(value: input, fromUnit: fromUnit, category: selectedCategory)
        return convertFromBase(value: baseValue, toUnit: toUnit, category: selectedCategory)
    }
    
    private func convertToBase(value: Double, fromUnit: Int, category: ConversionCategory) -> Double {
        switch category {
        case .length:
            let factors = [0.001, 0.01, 1.0, 1000.0, 0.0254, 0.3048, 0.9144, 1609.344] // to meters
            return value * factors[fromUnit]
            
        case .weight:
            let factors = [0.001, 1.0, 0.0283495, 0.453592, 6.35029, 1000.0, 907.185] // to kg
            return value * factors[fromUnit]
            
        case .temperature:
            switch fromUnit {
            case 0: return value + 273.15 // Celsius to Kelvin
            case 1: return (value - 32) * 5/9 + 273.15 // Fahrenheit to Kelvin
            case 2: return value // Kelvin
            default: return value
            }
            
        case .volume:
            let factors = [0.001, 1.0, 0.0295735, 0.236588, 0.473176, 0.946353, 3.78541] // to liters
            return value * factors[fromUnit]
            
        case .area:
            let factors = [1.0, 1000000.0, 0.092903, 0.836127, 4046.86, 10000.0] // to square meters
            return value * factors[fromUnit]
            
        case .speed:
            let factors = [1.0, 0.277778, 0.44704, 0.514444, 0.3048] // to m/s
            return value * factors[fromUnit]
        }
    }
    
    private func convertFromBase(value: Double, toUnit: Int, category: ConversionCategory) -> Double {
        switch category {
        case .length:
            let factors = [1000.0, 100.0, 1.0, 0.001, 39.3701, 3.28084, 1.09361, 0.000621371] // from meters
            return value * factors[toUnit]
            
        case .weight:
            let factors = [1000.0, 1.0, 35.274, 2.20462, 0.157473, 0.001, 0.00110231] // from kg
            return value * factors[toUnit]
            
        case .temperature:
            switch toUnit {
            case 0: return value - 273.15 // Kelvin to Celsius
            case 1: return (value - 273.15) * 9/5 + 32 // Kelvin to Fahrenheit
            case 2: return value // Kelvin
            default: return value
            }
            
        case .volume:
            let factors = [1000.0, 1.0, 33.814, 4.22675, 2.11338, 1.05669, 0.264172] // from liters
            return value * factors[toUnit]
            
        case .area:
            let factors = [1.0, 0.000001, 10.7639, 1.19599, 0.000247105, 0.0001] // from square meters
            return value * factors[toUnit]
            
        case .speed:
            let factors = [1.0, 3.6, 2.23694, 1.94384, 3.28084] // from m/s
            return value * factors[toUnit]
        }
    }
    
    var body: some View {
        CalculatorView(title: "Unit Converter", description: "Convert between units") {
            VStack(spacing: 20) {
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conversion Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ConversionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: selectedCategory) { _ in
                        // Reset unit selections when category changes
                        fromUnit = 0
                        toUnit = min(1, selectedCategory.units.count - 1)
                    }
                }
                
                // Input Value
                CalculatorInputField(
                    title: "Value to Convert",
                    value: $inputValue,
                    placeholder: "100"
                )
                
                // From Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("From Unit", selection: $fromUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text("\(selectedCategory.units[index]) (\(selectedCategory.abbreviations[index]))").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // To Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("To Unit", selection: $toUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text("\(selectedCategory.units[index]) (\(selectedCategory.abbreviations[index]))").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Quick swap button
                Button("Swap Units") {
                    let temp = fromUnit
                    fromUnit = toUnit
                    toUnit = temp
                }
                .buttonStyle(.bordered)
            
                // Calculate Button
                CalculatorButton(title: "Convert") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && !inputValue.isEmpty {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Conversion Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        VStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "\(inputValue) \(selectedCategory.abbreviations[fromUnit])",
                                value: String(format: "%.6g", convertedValue),
                                subtitle: selectedCategory.abbreviations[toUnit],
                                color: .blue
                            )
                            
                            // Conversion equation
                            Text("\(inputValue) \(selectedCategory.units[fromUnit]) = \(String(format: "%.6g", convertedValue)) \(selectedCategory.units[toUnit])")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Common Conversions for this category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common \(selectedCategory.rawValue) Conversions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                ForEach(getCommonConversions(), id: \.0) { conversion in
                                    InfoRow(
                                        label: conversion.0,
                                        value: conversion.1
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Multiple unit results
                        if selectedCategory.units.count > 2 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(inputValue) \(selectedCategory.abbreviations[fromUnit]) in other units:")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 6) {
                                    ForEach(0..<selectedCategory.units.count, id: \.self) { unitIndex in
                                        if unitIndex != fromUnit {
                                            let convertedVal = convertFromBase(
                                                value: convertToBase(value: Double(inputValue) ?? 0, fromUnit: fromUnit, category: selectedCategory),
                                                toUnit: unitIndex,
                                                category: selectedCategory
                                            )
                                            InfoRow(
                                                label: selectedCategory.units[unitIndex],
                                                value: "\(String(format: "%.6g", convertedVal)) \(selectedCategory.abbreviations[unitIndex])"
                                            )
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func getCommonConversions() -> [(String, String)] {
        switch selectedCategory {
        case .length:
            return [
                ("1 inch", "2.54 cm"),
                ("1 foot", "0.305 meters"),
                ("1 mile", "1.609 km"),
                ("1 meter", "3.281 feet")
            ]
        case .weight:
            return [
                ("1 pound", "0.454 kg"),
                ("1 ounce", "28.35 grams"),
                ("1 kilogram", "2.205 pounds"),
                ("1 stone", "14 pounds")
            ]
        case .temperature:
            return [
                ("0°C", "32°F"),
                ("100°C", "212°F"),
                ("Room temp", "20°C / 68°F"),
                ("Body temp", "37°C / 98.6°F")
            ]
        case .volume:
            return [
                ("1 gallon", "3.785 liters"),
                ("1 liter", "1.057 quarts"),
                ("1 cup", "237 ml"),
                ("1 fluid ounce", "29.6 ml")
            ]
        case .area:
            return [
                ("1 acre", "4,047 m²"),
                ("1 hectare", "2.471 acres"),
                ("1 sq foot", "0.093 m²"),
                ("1 sq mile", "259 hectares")
            ]
        case .speed:
            return [
                ("60 mph", "96.6 km/h"),
                ("100 km/h", "62.1 mph"),
                ("1 knot", "1.852 km/h"),
                ("Sound (sea level)", "343 m/s")
            ]
        }
    }
}

struct CurrencyConverterView: View {
    @State private var amount = ""
    @State private var fromCurrency = Currency.usd
    @State private var toCurrency = Currency.eur
    @State private var showResults = false
    
    enum Currency: String, CaseIterable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case jpy = "JPY"
        case cad = "CAD"
        case aud = "AUD"
        case chf = "CHF"
        case cny = "CNY"
        case inr = "INR"
        case krw = "KRW"
        
        var name: String {
            switch self {
            case .usd: return "US Dollar"
            case .eur: return "Euro"
            case .gbp: return "British Pound"
            case .jpy: return "Japanese Yen"
            case .cad: return "Canadian Dollar"
            case .aud: return "Australian Dollar"
            case .chf: return "Swiss Franc"
            case .cny: return "Chinese Yuan"
            case .inr: return "Indian Rupee"
            case .krw: return "South Korean Won"
            }
        }
        
        var symbol: String {
            switch self {
            case .usd, .cad, .aud: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            case .jpy, .cny: return "¥"
            case .chf: return "CHF"
            case .inr: return "₹"
            case .krw: return "₩"
            }
        }
        
        // Approximate exchange rates (in real app, would fetch from API)
        var rateToUSD: Double {
            switch self {
            case .usd: return 1.0
            case .eur: return 1.08
            case .gbp: return 1.27
            case .jpy: return 0.0067
            case .cad: return 0.74
            case .aud: return 0.66
            case .chf: return 1.11
            case .cny: return 0.14
            case .inr: return 0.012
            case .krw: return 0.00076
            }
        }
    }
    
    var convertedAmount: Double {
        guard let inputAmount = Double(amount), inputAmount > 0 else { return 0 }
        
        // Convert to USD first, then to target currency
        let usdAmount = inputAmount * fromCurrency.rateToUSD
        return usdAmount / toCurrency.rateToUSD
    }
    
    var exchangeRate: Double {
        fromCurrency.rateToUSD / toCurrency.rateToUSD
    }
    
    var body: some View {
        CalculatorView(title: "Currency Converter", description: "Convert between currencies") {
            VStack(spacing: 20) {
                // Amount Input
                CalculatorInputField(
                    title: "Amount",
                    value: $amount,
                    placeholder: "100"
                )
                
                // From Currency
                VStack(alignment: .leading, spacing: 8) {
                    Text("From Currency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("From Currency", selection: $fromCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text("\(currency.rawValue) - \(currency.name)").tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Swap Button
                Button("Swap Currencies") {
                    let temp = fromCurrency
                    fromCurrency = toCurrency
                    toCurrency = temp
                }
                .buttonStyle(.bordered)
                
                // To Currency
                VStack(alignment: .leading, spacing: 8) {
                    Text("To Currency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("To Currency", selection: $toCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text("\(currency.rawValue) - \(currency.name)").tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calculate Button
                CalculatorButton(title: "Convert Currency") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && convertedAmount > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Conversion Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "\(fromCurrency.symbol)\(amount) \(fromCurrency.rawValue)",
                            value: "\(toCurrency.symbol)\(String(format: "%.2f", convertedAmount))",
                            subtitle: toCurrency.rawValue,
                            color: .blue
                        )
                        
                        // Exchange Rate Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exchange Rate Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "1 \(fromCurrency.rawValue) =",
                                    value: "\(String(format: "%.4f", exchangeRate)) \(toCurrency.rawValue)"
                                )
                                InfoRow(
                                    label: "1 \(toCurrency.rawValue) =",
                                    value: "\(String(format: "%.4f", 1/exchangeRate)) \(fromCurrency.rawValue)"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Multiple Amount Conversions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Conversions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let quickAmounts = [10.0, 50.0, 100.0, 500.0, 1000.0]
                            VStack(spacing: 6) {
                                ForEach(quickAmounts, id: \.self) { quickAmount in
                                    let converted = quickAmount * exchangeRate
                                    InfoRow(
                                        label: "\(fromCurrency.symbol)\(Int(quickAmount)) \(fromCurrency.rawValue)",
                                        value: "\(toCurrency.symbol)\(String(format: "%.2f", converted)) \(toCurrency.rawValue)"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Historical Context (simulated)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rate Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let variation = Double.random(in: 0.95...1.05)
                            let pastRate = exchangeRate * variation
                            let difference = ((exchangeRate - pastRate) / pastRate) * 100
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Current rate",
                                    value: String(format: "%.4f", exchangeRate)
                                )
                                InfoRow(
                                    label: "30-day average*",
                                    value: String(format: "%.4f", pastRate)
                                )
                                InfoRow(
                                    label: "Change",
                                    value: "\(difference >= 0 ? "+" : "")\(String(format: "%.2f", difference))%"
                                )
                            }
                            
                            Text("*Simulated data for demonstration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Disclaimer
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Important Notice")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Exchange rates are approximate and for reference only")
                                Text("• Actual rates vary by provider and may include fees")
                                Text("• Rates fluctuate constantly during market hours")
                                Text("• Always check current rates before making transactions")
                                Text("• Consider transaction fees and spreads")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct SalesTaxCalculatorView: View {
    @State private var purchaseAmount = ""
    @State private var taxRate = ""
    @State private var calculationType = CalculationType.addTax
    @State private var showResults = false
    
    enum CalculationType: String, CaseIterable {
        case addTax = "Add Tax"
        case removeTax = "Remove Tax"
        
        var description: String {
            switch self {
            case .addTax: return "Calculate tax on pre-tax amount"
            case .removeTax: return "Calculate pre-tax amount from total"
            }
        }
    }
    
    var taxAmount: Double {
        guard let amount = Double(purchaseAmount),
              let rate = Double(taxRate),
              amount > 0, rate >= 0 else { return 0 }
        
        switch calculationType {
        case .addTax:
            return amount * (rate / 100)
        case .removeTax:
            return amount - (amount / (1 + rate / 100))
        }
    }
    
    var totalAmount: Double {
        guard let amount = Double(purchaseAmount) else { return 0 }
        
        switch calculationType {
        case .addTax:
            return amount + taxAmount
        case .removeTax:
            return amount
        }
    }
    
    var preTaxAmount: Double {
        guard let amount = Double(purchaseAmount),
              let rate = Double(taxRate),
              rate >= 0 else { return 0 }
        
        switch calculationType {
        case .addTax:
            return amount
        case .removeTax:
            return amount / (1 + rate / 100)
        }
    }
    
    var body: some View {
        CalculatorView(title: "Sales Tax", description: "Calculate tax on purchases") {
            VStack(spacing: 20) {
                // Calculation Type
                SegmentedPicker(
                    title: "Calculation Type",
                    selection: $calculationType,
                    options: CalculationType.allCases.map { ($0, $0.rawValue) }
                )
                
                Text(calculationType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Input Fields
                CalculatorInputField(
                    title: calculationType == .addTax ? "Purchase Amount (Pre-tax)" : "Total Amount (With Tax)",
                    value: $purchaseAmount,
                    placeholder: "100.00",
                    suffix: "$"
                )
                
                CalculatorInputField(
                    title: "Tax Rate",
                    value: $taxRate,
                    placeholder: "8.25",
                    suffix: "%"
                )
                
                // Common tax rates
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common Tax Rates")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(["5.0", "6.0", "7.0", "7.5", "8.0", "8.25", "8.5", "9.0", "10.0"], id: \.self) { rate in
                            Button(rate + "%") {
                                taxRate = rate
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            .foregroundColor(taxRate == rate ? .white : .blue)
                            .background(taxRate == rate ? Color.blue : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Tax") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && (Double(purchaseAmount) ?? 0) > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Tax Calculation")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Tax Amount",
                                value: NumberFormatter.formatCurrency(taxAmount),
                                color: .orange
                            )
                            
                            CalculatorResultCard(
                                title: calculationType == .addTax ? "Total Amount" : "Pre-tax Amount",
                                value: calculationType == .addTax ? 
                                    NumberFormatter.formatCurrency(totalAmount) :
                                    NumberFormatter.formatCurrency(preTaxAmount),
                                color: .blue
                            )
                        }
                        
                        // Detailed Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Pre-tax Amount",
                                    value: NumberFormatter.formatCurrency(preTaxAmount)
                                )
                                InfoRow(
                                    label: "Tax Rate",
                                    value: NumberFormatter.formatPercent(Double(taxRate) ?? 0)
                                )
                                InfoRow(
                                    label: "Tax Amount",
                                    value: NumberFormatter.formatCurrency(taxAmount)
                                )
                                Divider()
                                InfoRow(
                                    label: "Total Amount",
                                    value: NumberFormatter.formatCurrency(calculationType == .addTax ? totalAmount : Double(purchaseAmount) ?? 0)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Additional Info
                        if let rate = Double(taxRate), rate > 0 {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("For every $100 spent, you pay $\(String(format: "%.2f", rate)) in tax")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct PercentageCalculatorView: View {
    @State private var calculationType = CalculationType.percentOf
    @State private var value1 = ""
    @State private var value2 = ""
    @State private var originalValue = ""
    @State private var newValue = ""
    @State private var showResults = false
    
    enum CalculationType: String, CaseIterable {
        case percentOf = "What is X% of Y?"
        case whatPercent = "X is what % of Y?"
        case percentageChange = "Percentage Change"
        case increaseDecrease = "Increase/Decrease by %"
        
        var description: String {
            switch self {
            case .percentOf: return "Calculate a percentage of a number"
            case .whatPercent: return "Find what percentage one number is of another"
            case .percentageChange: return "Calculate percentage change between two values"
            case .increaseDecrease: return "Increase or decrease a number by a percentage"
            }
        }
    }
    
    var calculationResult: Double {
        switch calculationType {
        case .percentOf:
            guard let percent = Double(value1),
                  let number = Double(value2) else { return 0 }
            return (percent / 100) * number
            
        case .whatPercent:
            guard let numerator = Double(value1),
                  let denominator = Double(value2),
                  denominator != 0 else { return 0 }
            return (numerator / denominator) * 100
            
        case .percentageChange:
            guard let original = Double(originalValue),
                  let new = Double(newValue),
                  original != 0 else { return 0 }
            return ((new - original) / original) * 100
            
        case .increaseDecrease:
            guard let base = Double(value1),
                  let percent = Double(value2) else { return 0 }
            return base * (1 + percent / 100)
        }
    }
    
    var body: some View {
        CalculatorView(title: "Percentage Calculator", description: "Calculate percentages and changes") {
            VStack(spacing: 20) {
                // Calculation Type Selection
                SegmentedPicker(
                    title: "Calculation Type",
                    selection: $calculationType,
                    options: CalculationType.allCases.map { ($0, $0.rawValue) }
                )
                
                Text(calculationType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Input Fields based on calculation type
                Group {
                    switch calculationType {
                    case .percentOf:
                        CalculatorInputField(
                            title: "Percentage",
                            value: $value1,
                            placeholder: "20",
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "Of Number",
                            value: $value2,
                            placeholder: "100"
                        )
                        
                    case .whatPercent:
                        CalculatorInputField(
                            title: "First Number",
                            value: $value1,
                            placeholder: "25"
                        )
                        
                        CalculatorInputField(
                            title: "Is What % of",
                            value: $value2,
                            placeholder: "100"
                        )
                        
                    case .percentageChange:
                        CalculatorInputField(
                            title: "Original Value",
                            value: $originalValue,
                            placeholder: "100"
                        )
                        
                        CalculatorInputField(
                            title: "New Value",
                            value: $newValue,
                            placeholder: "120"
                        )
                        
                    case .increaseDecrease:
                        CalculatorInputField(
                            title: "Base Number",
                            value: $value1,
                            placeholder: "100"
                        )
                        
                        CalculatorInputField(
                            title: "Percentage Change",
                            value: $value2,
                            placeholder: "20",
                            suffix: "%"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        switch calculationType {
                        case .percentOf:
                            CalculatorResultCard(
                                title: "\(value1)% of \(value2) is",
                                value: NumberFormatter.formatDecimal(calculationResult),
                                color: .blue
                            )
                            
                        case .whatPercent:
                            CalculatorResultCard(
                                title: "\(value1) is",
                                value: NumberFormatter.formatPercent(calculationResult),
                                subtitle: "of \(value2)",
                                color: .green
                            )
                            
                        case .percentageChange:
                            let isIncrease = calculationResult >= 0
                            CalculatorResultCard(
                                title: isIncrease ? "Percentage Increase" : "Percentage Decrease",
                                value: NumberFormatter.formatPercent(abs(calculationResult)),
                                subtitle: "From \(originalValue) to \(newValue)",
                                color: isIncrease ? .green : .red
                            )
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Original Value",
                                    value: NumberFormatter.formatDecimal(Double(originalValue) ?? 0)
                                )
                                InfoRow(
                                    label: "New Value",
                                    value: NumberFormatter.formatDecimal(Double(newValue) ?? 0)
                                )
                                InfoRow(
                                    label: "Absolute Change",
                                    value: NumberFormatter.formatDecimal(abs((Double(newValue) ?? 0) - (Double(originalValue) ?? 0)))
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        case .increaseDecrease:
                            CalculatorResultCard(
                                title: "Result",
                                value: NumberFormatter.formatDecimal(calculationResult),
                                subtitle: "\(value1) \(Double(value2) ?? 0 >= 0 ? "+" : "")\(value2)%",
                                color: .purple
                            )
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Original Amount",
                                    value: NumberFormatter.formatDecimal(Double(value1) ?? 0)
                                )
                                InfoRow(
                                    label: "Change Amount",
                                    value: NumberFormatter.formatDecimal(calculationResult - (Double(value1) ?? 0))
                                )
                                InfoRow(
                                    label: "Final Amount",
                                    value: NumberFormatter.formatDecimal(calculationResult)
                                )
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
}

// Time & Date Placeholders
struct DateCalculatorView: View {
    @State private var calculationType = DateCalculationType.daysBetween
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 30) // 30 days from now
    @State private var baseDate = Date()
    @State private var daysToAdd = ""
    @State private var weeksToAdd = ""
    @State private var monthsToAdd = ""
    @State private var yearsToAdd = ""
    @State private var showResults = false
    
    enum DateCalculationType: String, CaseIterable {
        case daysBetween = "Days Between Dates"
        case addToDate = "Add Time to Date"
        case ageCalculator = "Age Calculator"
        
        var description: String {
            switch self {
            case .daysBetween: return "Calculate the difference between two dates"
            case .addToDate: return "Add days, weeks, months, or years to a date"
            case .ageCalculator: return "Calculate age in years, months, and days"
            }
        }
    }
    
    var daysBetweenDates: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    var detailedTimeBetween: (years: Int, months: Int, weeks: Int, days: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: startDate, to: endDate)
        return (
            years: components.year ?? 0,
            months: components.month ?? 0,
            weeks: components.weekOfYear ?? 0,
            days: components.day ?? 0
        )
    }
    
    var calculatedDate: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = Int(daysToAdd) ?? 0
        components.weekOfYear = Int(weeksToAdd) ?? 0
        components.month = Int(monthsToAdd) ?? 0
        components.year = Int(yearsToAdd) ?? 0
        
        return calendar.date(byAdding: components, to: baseDate) ?? baseDate
    }
    
    var ageComponents: (years: Int, months: Int, days: Int) {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: startDate, to: now)
        return (
            years: ageComponents.year ?? 0,
            months: ageComponents.month ?? 0,
            days: ageComponents.day ?? 0
        )
    }
    
    var totalDaysAlive: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        return components.day ?? 0
    }
    
    var body: some View {
        CalculatorView(title: "Date Calculator", description: "Calculate days between dates") {
            VStack(spacing: 20) {
                // Calculation Type Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calculation Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Calculation Type", selection: $calculationType) {
                        ForEach(DateCalculationType.allCases, id: \.self) { type in
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
                
                // Input Fields based on calculation type
                Group {
                    switch calculationType {
                    case .daysBetween:
                        VStack(spacing: 16) {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                    case .addToDate:
                        VStack(spacing: 16) {
                            DatePicker("Base Date", selection: $baseDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text("Add Time (enter values to add):")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 12) {
                                CalculatorInputField(
                                    title: "Years",
                                    value: $yearsToAdd,
                                    placeholder: "0",
                                    keyboardType: .numberPad
                                )
                                
                                CalculatorInputField(
                                    title: "Months",
                                    value: $monthsToAdd,
                                    placeholder: "0",
                                    keyboardType: .numberPad
                                )
                            }
                            
                            HStack(spacing: 12) {
                                CalculatorInputField(
                                    title: "Weeks",
                                    value: $weeksToAdd,
                                    placeholder: "0",
                                    keyboardType: .numberPad
                                )
                                
                                CalculatorInputField(
                                    title: "Days",
                                    value: $daysToAdd,
                                    placeholder: "0",
                                    keyboardType: .numberPad
                                )
                            }
                        }
                        
                    case .ageCalculator:
                        DatePicker("Birth Date", selection: $startDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate") {
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
                        
                        switch calculationType {
                        case .daysBetween:
                            VStack(spacing: 12) {
                                CalculatorResultCard(
                                    title: "Days Between",
                                    value: "\(abs(daysBetweenDates)) days",
                                    subtitle: daysBetweenDates >= 0 ? "Future date" : "Past date",
                                    color: .blue
                                )
                                
                                // Detailed breakdown
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Detailed Breakdown")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    let detailed = detailedTimeBetween
                                    VStack(spacing: 8) {
                                        if detailed.years != 0 {
                                            InfoRow(
                                                label: "Years",
                                                value: "\(abs(detailed.years))"
                                            )
                                        }
                                        if detailed.months != 0 {
                                            InfoRow(
                                                label: "Months",
                                                value: "\(abs(detailed.months))"
                                            )
                                        }
                                        if detailed.weeks != 0 {
                                            InfoRow(
                                                label: "Weeks",
                                                value: "\(abs(detailed.weeks))"
                                            )
                                        }
                                        InfoRow(
                                            label: "Total days",
                                            value: "\(abs(daysBetweenDates))"
                                        )
                                        InfoRow(
                                            label: "Total hours",
                                            value: "\(abs(daysBetweenDates * 24))"
                                        )
                                        InfoRow(
                                            label: "Total minutes",
                                            value: "\(abs(daysBetweenDates * 24 * 60))"
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                        case .addToDate:
                            VStack(spacing: 12) {
                                CalculatorResultCard(
                                    title: "Calculated Date",
                                    value: DateFormatter.longDateFormatter.string(from: calculatedDate),
                                    subtitle: DateFormatter.relativeDateFormatter.localizedString(for: calculatedDate, relativeTo: Date()),
                                    color: .green
                                )
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Summary")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(spacing: 8) {
                                        InfoRow(
                                            label: "Base date",
                                            value: DateFormatter.longDateFormatter.string(from: baseDate)
                                        )
                                        InfoRow(
                                            label: "Result date",
                                            value: DateFormatter.longDateFormatter.string(from: calculatedDate)
                                        )
                                        InfoRow(
                                            label: "Day of week",
                                            value: DateFormatter.dayOfWeekFormatter.string(from: calculatedDate)
                                        )
                                        let daysDiff = Calendar.current.dateComponents([.day], from: Date(), to: calculatedDate).day ?? 0
                                        InfoRow(
                                            label: "From today",
                                            value: "\(abs(daysDiff)) days \(daysDiff >= 0 ? "in the future" : "ago")"
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                        case .ageCalculator:
                            VStack(spacing: 12) {
                                let age = ageComponents
                                CalculatorResultCard(
                                    title: "Your Age",
                                    value: "\(age.years) years",
                                    subtitle: "\(age.months) months, \(age.days) days",
                                    color: .purple
                                )
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Age Details")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(spacing: 8) {
                                        InfoRow(
                                            label: "Birth date",
                                            value: DateFormatter.longDateFormatter.string(from: startDate)
                                        )
                                        InfoRow(
                                            label: "Days alive",
                                            value: "\(totalDaysAlive) days"
                                        )
                                        InfoRow(
                                            label: "Hours alive",
                                            value: "\(totalDaysAlive * 24) hours"
                                        )
                                        InfoRow(
                                            label: "Age in months",
                                            value: "\(age.years * 12 + age.months) months"
                                        )
                                        InfoRow(
                                            label: "Age in weeks",
                                            value: "\(totalDaysAlive / 7) weeks"
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // Fun facts
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("Fun Facts")
                                            .font(.headline)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("• You've experienced approximately \(age.years) New Year's celebrations")
                                        Text("• You've seen about \(age.years * 365 / 29) full moons")
                                        Text("• Your heart has beaten roughly \(totalDaysAlive * 100000) times")
                                        if age.years >= 18 {
                                            Text("• You've been an adult for \(age.years - 18) years")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemYellow).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}

struct TimeZoneConverterView: View {
    @State private var selectedTime = Date()
    @State private var fromTimeZone = TimeZoneOption.newYork
    @State private var toTimeZone = TimeZoneOption.london
    @State private var showResults = false
    
    enum TimeZoneOption: String, CaseIterable {
        case newYork = "New York (EST/EDT)"
        case losAngeles = "Los Angeles (PST/PDT)"
        case chicago = "Chicago (CST/CDT)"
        case denver = "Denver (MST/MDT)"
        case london = "London (GMT/BST)"
        case paris = "Paris (CET/CEST)"
        case tokyo = "Tokyo (JST)"
        case sydney = "Sydney (AEST/AEDT)"
        case dubai = "Dubai (GST)"
        case mumbai = "Mumbai (IST)"
        case shanghai = "Shanghai (CST)"
        case moscow = "Moscow (MSK)"
        
        var timeZone: TimeZone {
            switch self {
            case .newYork: return TimeZone(identifier: "America/New_York")!
            case .losAngeles: return TimeZone(identifier: "America/Los_Angeles")!
            case .chicago: return TimeZone(identifier: "America/Chicago")!
            case .denver: return TimeZone(identifier: "America/Denver")!
            case .london: return TimeZone(identifier: "Europe/London")!
            case .paris: return TimeZone(identifier: "Europe/Paris")!
            case .tokyo: return TimeZone(identifier: "Asia/Tokyo")!
            case .sydney: return TimeZone(identifier: "Australia/Sydney")!
            case .dubai: return TimeZone(identifier: "Asia/Dubai")!
            case .mumbai: return TimeZone(identifier: "Asia/Kolkata")!
            case .shanghai: return TimeZone(identifier: "Asia/Shanghai")!
            case .moscow: return TimeZone(identifier: "Europe/Moscow")!
            }
        }
        
        var abbreviation: String {
            timeZone.abbreviation() ?? ""
        }
    }
    
    var convertedTime: Date {
        // Time zones are handled automatically by Date, we just need to display them correctly
        return selectedTime
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var allTimeZoneResults: [(zone: TimeZoneOption, time: String)] {
        TimeZoneOption.allCases.map { zone in
            let formatter = dateTimeFormatter
            formatter.timeZone = zone.timeZone
            return (zone, formatter.string(from: selectedTime))
        }
    }
    
    var businessHourAnalysis: (fromStatus: String, toStatus: String, overlap: String) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        
        // Convert to target timezone hours
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        formatter.timeZone = fromTimeZone.timeZone
        let fromHour = Int(formatter.string(from: selectedTime)) ?? 0
        
        formatter.timeZone = toTimeZone.timeZone
        let toHour = Int(formatter.string(from: selectedTime)) ?? 0
        
        let fromStatus = (fromHour >= 9 && fromHour < 17) ? "Business Hours" : "Outside Business Hours"
        let toStatus = (toHour >= 9 && toHour < 17) ? "Business Hours" : "Outside Business Hours"
        
        let overlapDescription: String
        if fromStatus == "Business Hours" && toStatus == "Business Hours" {
            overlapDescription = "Good time for meetings!"
        } else if fromStatus == "Business Hours" || toStatus == "Business Hours" {
            overlapDescription = "One location is in business hours"
        } else {
            overlapDescription = "Both locations outside business hours"
        }
        
        return (fromStatus, toStatus, overlapDescription)
    }
    
    var body: some View {
        CalculatorView(title: "Time Zone Converter", description: "Convert between time zones") {
            VStack(spacing: 20) {
                // Time Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // From Time Zone
                VStack(alignment: .leading, spacing: 8) {
                    Text("From Time Zone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("From Time Zone", selection: $fromTimeZone) {
                        ForEach(TimeZoneOption.allCases, id: \.self) { timeZone in
                            Text(timeZone.rawValue).tag(timeZone)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Swap Button
                Button("Swap Time Zones") {
                    let temp = fromTimeZone
                    fromTimeZone = toTimeZone
                    toTimeZone = temp
                }
                .buttonStyle(.bordered)
                
                // To Time Zone
                VStack(alignment: .leading, spacing: 8) {
                    Text("To Time Zone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("To Time Zone", selection: $toTimeZone) {
                        ForEach(TimeZoneOption.allCases, id: \.self) { timeZone in
                            Text(timeZone.rawValue).tag(timeZone)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Convert Button
                CalculatorButton(title: "Convert Time") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Time Conversion")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Conversion Result
                        VStack(spacing: 12) {
                            // From Time
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fromTimeZone.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                let fromFormatter = dateTimeFormatter
                                fromFormatter.timeZone = fromTimeZone.timeZone
                                Text(fromFormatter.string(from: selectedTime))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Image(systemName: "arrow.down")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            // To Time
                            VStack(alignment: .leading, spacing: 4) {
                                Text(toTimeZone.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                let toFormatter = dateTimeFormatter
                                toFormatter.timeZone = toTimeZone.timeZone
                                Text(toFormatter.string(from: selectedTime))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Business Hours Analysis
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Business Hours Analysis")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let analysis = businessHourAnalysis
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: fromTimeZone.rawValue.components(separatedBy: " ").first ?? "",
                                    value: analysis.fromStatus
                                )
                                InfoRow(
                                    label: toTimeZone.rawValue.components(separatedBy: " ").first ?? "",
                                    value: analysis.toStatus
                                )
                                InfoRow(
                                    label: "Meeting suitability",
                                    value: analysis.overlap
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // World Clock
                        VStack(alignment: .leading, spacing: 12) {
                            Text("World Clock")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                ForEach(allTimeZoneResults.prefix(8), id: \.zone) { result in
                                    HStack {
                                        Text(result.zone.rawValue.components(separatedBy: " ").first ?? "")
                                            .font(.subheadline)
                                            .frame(width: 80, alignment: .leading)
                                        Spacer()
                                        Text(result.time)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Time Zone Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("Time Zone Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Consider daylight saving time changes")
                                Text("• Schedule meetings during overlapping business hours")
                                Text("• Use 'UTC' for international coordination")
                                Text("• Double-check time zones for important calls")
                                Text("• Consider cultural work hour differences")
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
        }
    }
}

struct OvertimeCalculatorView: View {
    @State private var hourlyRate = ""
    @State private var regularHours = "40"
    @State private var overtimeHours = ""
    @State private var overtimeMultiplier = "1.5"
    @State private var doubleTimeHours = ""
    @State private var doubleTimeMultiplier = "2.0"
    @State private var showResults = false
    
    var regularPay: Double {
        let rate = Double(hourlyRate) ?? 0
        let hours = Double(regularHours) ?? 0
        return rate * hours
    }
    
    var overtimePay: Double {
        let rate = Double(hourlyRate) ?? 0
        let hours = Double(overtimeHours) ?? 0
        let multiplier = Double(overtimeMultiplier) ?? 1.5
        return rate * multiplier * hours
    }
    
    var doubleTimePay: Double {
        let rate = Double(hourlyRate) ?? 0
        let hours = Double(doubleTimeHours) ?? 0
        let multiplier = Double(doubleTimeMultiplier) ?? 2.0
        return rate * multiplier * hours
    }
    
    var totalPay: Double {
        regularPay + overtimePay + doubleTimePay
    }
    
    var totalHours: Double {
        (Double(regularHours) ?? 0) + (Double(overtimeHours) ?? 0) + (Double(doubleTimeHours) ?? 0)
    }
    
    var averageHourlyRate: Double {
        guard totalHours > 0 else { return 0 }
        return totalPay / totalHours
    }
    
    var body: some View {
        CalculatorView(title: "Overtime Calculator", description: "Calculate overtime pay") {
            VStack(spacing: 20) {
                // Basic Rate
                CalculatorInputField(
                    title: "Regular Hourly Rate",
                    value: $hourlyRate,
                    placeholder: "25.00",
                    suffix: "$/hour"
                )
                
                // Regular Hours
                CalculatorInputField(
                    title: "Regular Hours",
                    value: $regularHours,
                    placeholder: "40",
                    keyboardType: .numberPad,
                    suffix: "hours"
                )
                
                // Overtime Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overtime (1.5x rate)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Overtime Hours",
                            value: $overtimeHours,
                            placeholder: "10",
                            keyboardType: .numberPad,
                            suffix: "hours"
                        )
                        
                        CalculatorInputField(
                            title: "Multiplier",
                            value: $overtimeMultiplier,
                            placeholder: "1.5",
                            suffix: "x"
                        )
                    }
                }
                
                // Double Time Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Double Time (2.0x rate)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        CalculatorInputField(
                            title: "Double Time Hours",
                            value: $doubleTimeHours,
                            placeholder: "0",
                            keyboardType: .numberPad,
                            suffix: "hours"
                        )
                        
                        CalculatorInputField(
                            title: "Multiplier",
                            value: $doubleTimeMultiplier,
                            placeholder: "2.0",
                            suffix: "x"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Pay") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && totalPay > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Overtime Pay Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Total Pay
                        CalculatorResultCard(
                            title: "Total Pay",
                            value: NumberFormatter.formatCurrency(totalPay),
                            subtitle: "\(String(format: "%.1f", totalHours)) total hours",
                            color: .green
                        )
                        
                        // Pay Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pay Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                if regularPay > 0 {
                                    InfoRow(
                                        label: "Regular Pay (\(regularHours) hrs)",
                                        value: NumberFormatter.formatCurrency(regularPay)
                                    )
                                }
                                if overtimePay > 0 {
                                    InfoRow(
                                        label: "Overtime Pay (\(overtimeHours) hrs @ \(overtimeMultiplier)x)",
                                        value: NumberFormatter.formatCurrency(overtimePay)
                                    )
                                }
                                if doubleTimePay > 0 {
                                    InfoRow(
                                        label: "Double Time (\(doubleTimeHours) hrs @ \(doubleTimeMultiplier)x)",
                                        value: NumberFormatter.formatCurrency(doubleTimePay)
                                    )
                                }
                                Divider()
                                InfoRow(
                                    label: "Total Gross Pay",
                                    value: NumberFormatter.formatCurrency(totalPay)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Rate Analysis
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rate Analysis")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Regular hourly rate",
                                    value: NumberFormatter.formatCurrency(Double(hourlyRate) ?? 0)
                                )
                                if (Double(overtimeHours) ?? 0) > 0 {
                                    InfoRow(
                                        label: "Overtime rate",
                                        value: NumberFormatter.formatCurrency((Double(hourlyRate) ?? 0) * (Double(overtimeMultiplier) ?? 1.5))
                                    )
                                }
                                if (Double(doubleTimeHours) ?? 0) > 0 {
                                    InfoRow(
                                        label: "Double time rate",
                                        value: NumberFormatter.formatCurrency((Double(hourlyRate) ?? 0) * (Double(doubleTimeMultiplier) ?? 2.0))
                                    )
                                }
                                InfoRow(
                                    label: "Effective hourly rate",
                                    value: NumberFormatter.formatCurrency(averageHourlyRate)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Monthly/Annual Projections
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Projections (if consistent)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Weekly pay",
                                    value: NumberFormatter.formatCurrency(totalPay)
                                )
                                InfoRow(
                                    label: "Monthly pay (4.33 weeks)",
                                    value: NumberFormatter.formatCurrency(totalPay * 4.33)
                                )
                                InfoRow(
                                    label: "Annual pay (52 weeks)",
                                    value: NumberFormatter.formatCurrency(totalPay * 52)
                                )
                            }
                            
                            Text("*Assumes consistent hours and excludes taxes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Overtime Laws Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Overtime Laws (US)")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Federal law requires 1.5x pay for hours over 40/week")
                                Text("• Some states have daily overtime (e.g., over 8 hours/day)")
                                Text("• Double time often applies after 12 hours/day")
                                Text("• Weekend and holiday rates vary by employer")
                                Text("• Some employees are exempt from overtime laws")
                                Text("• Check your local and state laws for specifics")
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
        }
    }
}