import SwiftUI

struct BudgetPlannerView: View {
    @State private var monthlyIncome = ""
    @State private var budgetRule = BudgetRule.fiftyThirtyTwenty
    @State private var customNeeds = "50"
    @State private var customWants = "30"
    @State private var customSavings = "20"
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: BudgetField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum BudgetField: CaseIterable {
        case monthlyIncome, customNeeds, customWants, customSavings
    }
    
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
        ScrollViewReader { proxy in
            CalculatorView(title: "Budget Planner", description: "50/30/20 rule budget calculator") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Income Input
                    GroupedInputFields(
                        title: "Income",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Monthly Take-Home Income",
                            value: $monthlyIncome,
                            placeholder: "5,000",
                            prefix: "$",
                            icon: "banknote.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Your after-tax monthly income",
                            onNext: { focusNextField(.monthlyIncome) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .monthlyIncome)
                        .id(BudgetField.monthlyIncome)
                    }
                
                // Budget Rule Selection
                GroupedInputFields(
                    title: "Budget Method",
                    icon: "chart.pie.fill",
                    color: .blue
                ) {
                    VStack(alignment: .leading, spacing: 12) {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Custom percentages (if custom rule selected)
                if budgetRule == .custom {
                    GroupedInputFields(
                        title: "Custom Percentages",
                        icon: "slider.horizontal.3",
                        color: .purple
                    ) {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                CompactInputField(
                                    title: "Needs",
                                    value: $customNeeds,
                                    placeholder: "50",
                                    suffix: "%",
                                    color: .red,
                                    keyboardType: .decimalPad,
                                    onPrevious: { focusPreviousField(.customNeeds) },
                                    onNext: { focusNextField(.customNeeds) },
                                    onDone: { focusedField = nil }
                                )
                                .focused($focusedField, equals: .customNeeds)
                                .id(BudgetField.customNeeds)
                                
                                CompactInputField(
                                    title: "Wants",
                                    value: $customWants,
                                    placeholder: "30",
                                    suffix: "%",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { focusPreviousField(.customWants) },
                                    onNext: { focusNextField(.customWants) },
                                    onDone: { focusedField = nil }
                                )
                                .focused($focusedField, equals: .customWants)
                                .id(BudgetField.customWants)
                                
                                CompactInputField(
                                    title: "Savings",
                                    value: $customSavings,
                                    placeholder: "20",
                                    suffix: "%",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { focusPreviousField(.customSavings) },
                                    onNext: { focusedField = nil },
                                    onDone: { focusedField = nil },
                                    showNextButton: false
                                )
                                .focused($focusedField, equals: .customSavings)
                                .id(BudgetField.customSavings)
                            }
                            
                            let total = (Double(customNeeds) ?? 0) + (Double(customWants) ?? 0) + (Double(customSavings) ?? 0)
                            if total != 100 {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Percentages should total 100% (currently \(Int(total))%)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Create Budget Plan") {
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
                if showResults && income > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
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
            BudgetInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: BudgetField) {
        let allFields = BudgetField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: BudgetField) {
        let allFields = BudgetField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        monthlyIncome = "5000"
        budgetRule = .fiftyThirtyTwenty
        customNeeds = "50"
        customWants = "30"
        customSavings = "20"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        monthlyIncome = ""
        budgetRule = .fiftyThirtyTwenty
        customNeeds = "50"
        customWants = "30"
        customSavings = "20"
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Budget Plan Results:
        Monthly Income: $\(monthlyIncome)
        Budget Method: \(budgetRule.rawValue)
        
        Budget Allocation:
        Needs (\(Int(budgetPercentages.needs))%): \(NumberFormatter.formatCurrency(budgetAmounts.needs))
        Wants (\(Int(budgetPercentages.wants))%): \(NumberFormatter.formatCurrency(budgetAmounts.wants))
        Savings (\(Int(budgetPercentages.savings))%): \(NumberFormatter.formatCurrency(budgetAmounts.savings))
        
        Annual Savings: \(NumberFormatter.formatCurrency(annualSavings))
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

struct BudgetInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Budget Planner")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you allocate your monthly income across needs, wants, and savings using popular budgeting methods like the 50/30/20 rule."
                        )
                        
                        InfoSection(
                            title: "Budget Methods",
                            content: """
                            • 50/30/20 Rule: 50% needs, 30% wants, 20% savings
                            • 60/20/20 Rule: 60% needs, 20% wants, 20% savings
                            • 70/20/10 Rule: 70% needs, 20% wants, 10% savings
                            • Custom: Set your own percentages
                            """
                        )
                        
                        InfoSection(
                            title: "Categories",
                            content: """
                            Needs: Housing, transportation, food, healthcare
                            Wants: Entertainment, dining out, shopping, hobbies
                            Savings: Emergency fund, retirement, goals, debt payoff
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • Start with the 50/30/20 rule as a baseline
                            • Adjust percentages based on your life situation
                            • Prioritize emergency fund before other goals
                            • Review and adjust monthly as needed
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Budget Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}