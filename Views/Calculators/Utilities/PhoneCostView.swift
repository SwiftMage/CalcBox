import SwiftUI

struct PhoneCostView: View {
    @State private var monthlyBill = ""
    @State private var minutesUsed = ""
    @State private var dataUsed = ""
    @State private var textsSent = ""
    @State private var planType = PlanType.unlimited
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: PhoneCostField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum PhoneCostField: CaseIterable {
        case monthlyBill, minutesUsed, dataUsed, textsSent
    }
    
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
        ScrollViewReader { proxy in
            CalculatorView(title: "Phone Cost Per Minute", description: "Calculate phone usage costs") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
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
                    ModernInputField(
                        title: "Monthly Phone Bill",
                        value: $monthlyBill,
                        placeholder: "85.00",
                        prefix: "$",
                        icon: "iphone.circle.fill",
                        color: .blue,
                        keyboardType: .decimalPad,
                        helpText: "Your total monthly phone bill amount",
                        onNext: { focusNextField(.monthlyBill) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .monthlyBill)
                    .id(PhoneCostField.monthlyBill)
                    
                    ModernInputField(
                        title: "Minutes Used",
                        value: $minutesUsed,
                        placeholder: "450",
                        suffix: "minutes",
                        icon: "phone.circle.fill",
                        color: .green,
                        keyboardType: .numberPad,
                        helpText: "Total voice call minutes used this month",
                        onPrevious: { focusPreviousField(.minutesUsed) },
                        onNext: { focusNextField(.minutesUsed) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .minutesUsed)
                    .id(PhoneCostField.minutesUsed)
                    
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Data Used",
                            value: $dataUsed,
                            placeholder: "8.5",
                            suffix: "GB",
                            color: .orange,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.dataUsed) },
                            onNext: { focusNextField(.dataUsed) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .dataUsed)
                        .id(PhoneCostField.dataUsed)
                        
                        CompactInputField(
                            title: "Text Messages",
                            value: $textsSent,
                            placeholder: "300",
                            suffix: "texts",
                            color: .purple,
                            keyboardType: .numberPad,
                            onPrevious: { focusPreviousField(.textsSent) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .textsSent)
                        .id(PhoneCostField.textsSent)
                    }
                
                // Calculate Button
                CalculatorButton(title: "Analyze Phone Costs") {
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
                if showResults && totalBill > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
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
            PhoneCostInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: PhoneCostField) {
        let allFields = PhoneCostField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: PhoneCostField) {
        let allFields = PhoneCostField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        monthlyBill = "85"
        minutesUsed = "450"
        dataUsed = "8.5"
        textsSent = "300"
        planType = .unlimited
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        monthlyBill = ""
        minutesUsed = ""
        dataUsed = ""
        textsSent = ""
        planType = .unlimited
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Phone Cost Analysis:
        Monthly Bill: \(NumberFormatter.formatCurrency(totalBill))
        Plan Efficiency: \(efficiencyRating.rating)
        Cost per minute: \(NumberFormatter.formatCurrency(costPerMinute))
        Daily cost: \(NumberFormatter.formatCurrency(dailyCost))
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

struct PhoneCostInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Phone Cost Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator analyzes your phone usage costs by breaking down your monthly bill across talk, text, and data usage to find your cost per unit."
                        )
                        
                        InfoSection(
                            title: "Plan types",
                            content: """
                            • Unlimited: Fixed monthly cost for unlimited usage
                            • Limited Minutes: Fixed allowance with overages
                            • Pay Per Use: Charge for each minute/text/MB
                            """
                        )
                        
                        InfoSection(
                            title: "Cost calculations",
                            content: """
                            • Cost per minute: Monthly bill ÷ minutes used
                            • Cost per text: Monthly bill ÷ texts sent
                            • Cost per GB: Monthly bill ÷ data used
                            • Daily cost: Monthly bill ÷ 30 days
                            """
                        )
                        
                        InfoSection(
                            title: "Money-saving tips",
                            content: """
                            • Use Wi-Fi when available to save data
                            • Monitor usage with carrier apps
                            • Consider family plans for multiple lines
                            • Review and remove unused features
                            • Compare plans if usage patterns change
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Phone Cost Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}