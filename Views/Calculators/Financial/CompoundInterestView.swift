import SwiftUI
import Charts

struct CompoundInterestView: View {
    @State private var principal = ""
    @State private var monthlyContribution = ""
    @State private var interestRate = ""
    @State private var years = ""
    @State private var compoundFrequency = CompoundFrequency.monthly
    @State private var timePeriod = TimePeriod.years10
    
    @State private var showResults = false
    @State private var yearlyBreakdown: [YearlyBreakdown] = []
    @State private var showYearlyTable = false
    
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
    
    enum TimePeriod: Int, CaseIterable {
        case years5 = 5
        case years10 = 10
        case years15 = 15
        case years20 = 20
        case years25 = 25
        case years30 = 30
        case custom = 0
        
        var displayName: String {
            switch self {
            case .years5: return "5 Years"
            case .years10: return "10 Years"
            case .years15: return "15 Years"
            case .years20: return "20 Years"
            case .years25: return "25 Years"
            case .years30: return "30 Years"
            case .custom: return "Custom"
            }
        }
        
        var yearsValue: String {
            return rawValue == 0 ? "" : String(rawValue)
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
            VStack(spacing: 24) {
                // Enhanced Input Fields Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Investment Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 16) {
                        EnhancedInputField(
                            title: "Initial Investment",
                            value: $principal,
                            placeholder: "10,000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        
                        EnhancedInputField(
                            title: "Monthly Contribution",
                            value: $monthlyContribution,
                            placeholder: "500",
                            prefix: "$",
                            icon: "calendar.badge.plus",
                            color: .blue
                        )
                        
                        EnhancedInputField(
                            title: "Annual Interest Rate",
                            value: $interestRate,
                            placeholder: "7.0",
                            suffix: "%",
                            icon: "percent",
                            color: .orange
                        )
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Time Period Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Investment Period")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Quick Time Period Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                TimePeriodButton(
                                    period: period,
                                    isSelected: timePeriod == period,
                                    action: {
                                        timePeriod = period
                                        if period != .custom {
                                            years = period.yearsValue
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Custom years input (only show if custom is selected)
                    if timePeriod == .custom {
                        EnhancedInputField(
                            title: "Custom Years",
                            value: $years,
                            placeholder: "25",
                            suffix: "years",
                            icon: "calendar",
                            color: .purple
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Compound Frequency
                VStack(alignment: .leading, spacing: 16) {
                    Text("Compound Frequency")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Picker("Compound Frequency", selection: $compoundFrequency) {
                        ForEach(CompoundFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
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
                        
                        // Yearly Breakdown Table
                        if !yearlyBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Yearly Breakdown")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            showYearlyTable.toggle()
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Text(showYearlyTable ? "Hide Table" : "Show Table")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Image(systemName: showYearlyTable ? "chevron.up" : "chevron.down")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                
                                if showYearlyTable {
                                    YearlyBreakdownTable(yearlyData: yearlyBreakdown)
                                        .transition(.move(edge: .top).combined(with: .opacity))
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
        .onChange(of: years) { newValue in
            // Update time period selection when years changes manually
            if let yearValue = Double(newValue), yearValue > 0 {
                let intYears = Int(yearValue)
                if let matchingPeriod = TimePeriod.allCases.first(where: { $0.rawValue == intYears }) {
                    timePeriod = matchingPeriod
                } else {
                    timePeriod = .custom
                }
            }
        }
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
}

// MARK: - Enhanced UI Components

struct EnhancedInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let prefix: String?
    let suffix: String?
    let icon: String
    let color: Color
    
    init(
        title: String,
        value: Binding<String>,
        placeholder: String,
        prefix: String? = nil,
        suffix: String? = nil,
        icon: String,
        color: Color
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.prefix = prefix
        self.suffix = suffix
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 8) {
                if let prefix = prefix {
                    Text(prefix)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
                
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .fontWeight(.medium)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct TimePeriodButton: View {
    let period: CompoundInterestView.TimePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct YearlyBreakdownTable: View {
    let yearlyData: [CompoundInterestView.YearlyBreakdown]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Year")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                Text("Principal")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("Interest")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("Total")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray4))
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(yearlyData) { item in
                        HStack {
                            Text("\(item.year)")
                                .font(.system(.subheadline, design: .monospaced))
                                .frame(width: 40, alignment: .leading)
                            
                            Text(NumberFormatter.formatCurrency(item.principal))
                                .font(.system(.subheadline, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(NumberFormatter.formatCurrency(item.interest))
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(NumberFormatter.formatCurrency(item.total))
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(item.year % 2 == 0 ? Color(.systemGray6) : Color(.systemBackground))
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        CompoundInterestView()
    }
}