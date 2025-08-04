import SwiftUI

struct InvestmentReturnsView: View {
    @State private var initialInvestment = ""
    @State private var currentValue = ""
    @State private var additionalContributions = ""
    @State private var timeHeld = ""
    @State private var timeUnit = TimeUnit.years
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: InvestmentField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum InvestmentField: CaseIterable {
        case initialInvestment, additionalContributions, currentValue, timeHeld
    }
    
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
        ScrollViewReader { proxy in
            CalculatorView(title: "Investment Returns", description: "Track portfolio performance") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Investment Details
                    GroupedInputFields(
                        title: "Investment Details",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    ) {
                        ModernInputField(
                            title: "Initial Investment",
                            value: $initialInvestment,
                            placeholder: "10000",
                            prefix: "$",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Original amount invested",
                            onNext: { focusNextField(.initialInvestment) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .initialInvestment)
                        .id(InvestmentField.initialInvestment)
                        
                        ModernInputField(
                            title: "Additional Contributions",
                            value: $additionalContributions,
                            placeholder: "5000",
                            prefix: "$",
                            icon: "plus.circle.fill",
                            color: .blue,
                            keyboardType: .decimalPad,
                            helpText: "Total additional contributions made",
                            onPrevious: { focusPreviousField(.additionalContributions) },
                            onNext: { focusNextField(.additionalContributions) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .additionalContributions)
                        .id(InvestmentField.additionalContributions)
                        
                        ModernInputField(
                            title: "Current Portfolio Value",
                            value: $currentValue,
                            placeholder: "18500",
                            prefix: "$",
                            icon: "chart.bar.fill",
                            color: .orange,
                            keyboardType: .decimalPad,
                            helpText: "Current market value of portfolio",
                            onPrevious: { focusPreviousField(.currentValue) },
                            onNext: { focusNextField(.currentValue) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .currentValue)
                        .id(InvestmentField.currentValue)
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Time Held",
                                value: $timeHeld,
                                placeholder: "3",
                                color: .purple,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.timeHeld) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .timeHeld)
                            .id(InvestmentField.timeHeld)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time Unit")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                
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
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Analyze Returns") {
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
                    if showResults && currentPortfolioValue > 0 && totalInvested > 0 {
                        VStack(spacing: 16) {
                            Divider()
                                .id("results")
                        
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
            InvestmentInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: InvestmentField) {
        let allFields = InvestmentField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: InvestmentField) {
        let allFields = InvestmentField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        initialInvestment = "10000"
        additionalContributions = "5000"
        currentValue = "18500"
        timeHeld = "3"
        timeUnit = .years
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        initialInvestment = ""
        additionalContributions = ""
        currentValue = ""
        timeHeld = ""
        timeUnit = .years
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Investment Returns Analysis:
        Initial Investment: $\(initialInvestment)
        Additional Contributions: $\(additionalContributions)
        Current Value: $\(currentValue)
        Total Return: \(NumberFormatter.formatCurrency(totalReturn))
        Return Percentage: \(NumberFormatter.formatPercent(returnPercentage))
        Annualized Return: \(NumberFormatter.formatPercent(annualizedReturn))
        Performance Rating: \(performanceRating.rating)
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

struct InvestmentInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Investment Returns Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator analyzes your investment performance by comparing your total invested amount with current portfolio value to determine returns and annualized performance."
                        )
                        
                        InfoSection(
                            title: "Key Metrics",
                            content: """
                            • Total Return: Gain or loss from investments
                            • Return Percentage: Return as % of total invested
                            • Annualized Return: Average yearly return rate
                            • Performance Rating: How your returns compare to benchmarks
                            """
                        )
                        
                        InfoSection(
                            title: "Investment Tips",
                            content: """
                            • Diversify across different asset classes
                            • Consider low-cost index funds for long-term growth
                            • Don't try to time the market
                            • Review and rebalance periodically
                            • Keep investment costs and fees low
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