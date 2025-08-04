import SwiftUI
import Combine

enum EmergencyFundField: CaseIterable {
    case monthlyExpenses
    case currentSavings
    case monthlySavings
    case interestRate
    case targetMonths
    
    var id: String {
        switch self {
        case .monthlyExpenses: return "monthly-expenses"
        case .currentSavings: return "current-savings"
        case .monthlySavings: return "monthly-savings"
        case .interestRate: return "interest-rate"
        case .targetMonths: return "target-months"
        }
    }
}

struct EmergencyFundView: View {
    @State private var monthlyExpenses = ""
    @State private var currentSavings = ""
    @State private var monthlySavings = ""
    @State private var interestRate = ""
    @State private var targetMonths = ""
    @State private var selectedMode = CalculationMode.buildFund
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: EmergencyFundField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum CalculationMode: String, CaseIterable {
        case buildFund = "Build Fund"
        case howLong = "Time to Goal"
        case howMuch = "Monthly Needed"
        
        var description: String {
            switch self {
            case .buildFund: return "Calculate how to build your emergency fund"
            case .howLong: return "How long to reach your goal?"
            case .howMuch: return "How much to save monthly?"
            }
        }
        
        var icon: String {
            switch self {
            case .buildFund: return "building.2.fill"
            case .howLong: return "clock.fill"
            case .howMuch: return "dollarsign.circle.fill"
            }
        }
    }
    
    private var calculationResults: EmergencyFundResults {
        calculateEmergencyFund()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Emergency Fund Calculator", description: "Plan and track your emergency savings") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Calculation Mode Selector
                    GroupedInputFields(title: "Calculation Mode", icon: "gear.circle.fill", color: .blue) {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(CalculationMode.allCases, id: \.self) { mode in
                                HStack {
                                    Image(systemName: mode.icon)
                                    Text(mode.rawValue)
                                }
                                .tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Basic Information
                    GroupedInputFields(title: "Your Expenses", icon: "list.bullet.rectangle.fill", color: .red) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Monthly Expenses",
                                value: $monthlyExpenses,
                                placeholder: "4500",
                                prefix: "$",
                                icon: "creditcard.fill",
                                color: .red,
                                keyboardType: .decimalPad,
                                helpText: "Total essential monthly expenses (rent, utilities, food, etc.)",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .monthlyExpenses)
                            .id(EmergencyFundField.monthlyExpenses)
                            
                            ModernInputField(
                                title: "Target Coverage",
                                value: $targetMonths,
                                placeholder: "6",
                                suffix: "months",
                                icon: "calendar.badge.clock",
                                color: .red,
                                keyboardType: .decimalPad,
                                helpText: "Recommended: 3-6 months for stable jobs, 6-12 for variable income",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .targetMonths)
                            .id(EmergencyFundField.targetMonths)
                        }
                    }
                    
                    // Current Situation
                    GroupedInputFields(title: "Current Situation", icon: "banknote.fill", color: .green) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Current Emergency Savings",
                                value: $currentSavings,
                                placeholder: "2000",
                                prefix: "$",
                                icon: "dollarsign.square.fill",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Money already set aside for emergencies",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .currentSavings)
                            .id(EmergencyFundField.currentSavings)
                            
                            if selectedMode != .howMuch {
                                ModernInputField(
                                    title: "Monthly Savings Amount",
                                    value: $monthlySavings,
                                    placeholder: "500",
                                    prefix: "$",
                                    icon: "arrow.up.circle.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    helpText: "How much you can save each month",
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .monthlySavings)
                                .id(EmergencyFundField.monthlySavings)
                            }
                            
                            ModernInputField(
                                title: "Savings Account Interest Rate",
                                value: $interestRate,
                                placeholder: "4.5",
                                suffix: "%",
                                icon: "percent",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Annual interest rate on your savings account",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .interestRate)
                            .id(EmergencyFundField.interestRate)
                        }
                    }
                    
                    // Calculate Button
                    Button(action: {
                        withAnimation {
                            showResults = true
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedMode.icon)
                            Text("Calculate Emergency Fund")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!canCalculate)
                    
                    if showResults && canCalculate {
                        VStack(spacing: 20) {
                            // Target Fund Summary
                            CalculatorResultCard(
                                title: "Emergency Fund Target",
                                value: "$\(String(format: "%.0f", calculationResults.targetAmount))",
                                subtitle: "\(targetMonths) months of expenses",
                                color: .blue
                            )
                            .id("results")
                            
                            // Progress Overview
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.pie.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text("Current Progress")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                // Progress Bar
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("$\(String(format: "%.0f", calculationResults.currentAmount))")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("\(String(format: "%.1f", calculationResults.progressPercentage))%")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray5))
                                                .frame(height: 20)
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.green, Color.blue],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(
                                                    width: geometry.size.width * min(calculationResults.progressPercentage / 100, 1.0),
                                                    height: 20
                                                )
                                        }
                                    }
                                    .frame(height: 20)
                                }
                                
                                HStack {
                                    Text("Remaining: $\(String(format: "%.0f", max(0, calculationResults.remainingAmount)))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    if calculationResults.progressPercentage >= 100 {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Goal Achieved!")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Mode-specific Results
                            switch selectedMode {
                            case .buildFund, .howLong:
                                if calculationResults.monthsToGoal > 0 {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "clock.badge.checkmark")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                            
                                            Text("Timeline to Goal")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                        }
                                        
                                        HStack(spacing: 20) {
                                            VStack {
                                                Text("\(calculationResults.monthsToGoal)")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.blue)
                                                Text("months")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            VStack {
                                                Text("\(String(format: "%.1f", Double(calculationResults.monthsToGoal) / 12))")
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.green)
                                                Text("years")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        if let goalDate = calculationResults.goalDate {
                                            HStack {
                                                Image(systemName: "calendar.badge.checkmark")
                                                    .foregroundColor(.blue)
                                                Text("Goal Date: \(goalDate, formatter: dateFormatter)")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                            case .howMuch:
                                VStack(spacing: 16) {
                                    HStack {
                                        Image(systemName: "dollarsign.arrow.circlepath")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                        
                                        Text("Monthly Savings Needed")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("To reach goal in 1 year:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", calculationResults.monthlySavingsFor1Year))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("To reach goal in 2 years:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", calculationResults.monthlySavingsFor2Years))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("To reach goal in 3 years:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", calculationResults.monthlySavingsFor3Years))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            // Emergency Fund Guidelines
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title2)
                                    
                                    Text("Emergency Fund Guidelines")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 12) {
                                    GuidelineRow(
                                        title: "3 months",
                                        description: "Stable job, dual income",
                                        amount: calculationResults.threeMonthTarget,
                                        isRecommended: calculationResults.recommendedMonths <= 3
                                    )
                                    
                                    GuidelineRow(
                                        title: "6 months",
                                        description: "Standard recommendation",
                                        amount: calculationResults.sixMonthTarget,
                                        isRecommended: calculationResults.recommendedMonths == 6
                                    )
                                    
                                    GuidelineRow(
                                        title: "12 months",
                                        description: "Variable income, self-employed",
                                        amount: calculationResults.twelveMonthTarget,
                                        isRecommended: calculationResults.recommendedMonths >= 12
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Interest Earnings
                            if calculationResults.annualInterestEarnings > 0 {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.green)
                                            .font(.title2)
                                        
                                        Text("Interest Earnings")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Your emergency fund will earn approximately $\(String(format: "%.0f", calculationResults.annualInterestEarnings)) per year in interest at \(interestRate)% APY.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
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
            EmergencyFundInfoSheet()
        }
    }
    
    private var canCalculate: Bool {
        !monthlyExpenses.isEmpty && !targetMonths.isEmpty && !currentSavings.isEmpty &&
        (selectedMode == .howMuch || !monthlySavings.isEmpty)
    }
    
    private func calculateEmergencyFund() -> EmergencyFundResults {
        let expenses = Double(monthlyExpenses) ?? 0
        let months = Double(targetMonths) ?? 6
        let current = Double(currentSavings) ?? 0
        let monthly = Double(monthlySavings) ?? 0
        let rate = (Double(interestRate) ?? 0) / 100
        
        let targetAmount = expenses * months
        let remainingAmount = max(0, targetAmount - current)
        let progressPercentage = targetAmount > 0 ? (current / targetAmount) * 100 : 0
        
        // Calculate months to goal with compound interest
        var monthsToGoal = 0
        if remainingAmount > 0 && monthly > 0 {
            let monthlyRate = rate / 12
            if monthlyRate > 0 {
                // Formula for future value of annuity with present value
                let pv = current
                let fv = targetAmount
                let pmt = monthly
                
                // Approximate calculation for months needed
                var balance = pv
                while balance < targetAmount && monthsToGoal < 600 { // 50 years max
                    balance = balance * (1 + monthlyRate) + pmt
                    monthsToGoal += 1
                }
            } else {
                monthsToGoal = Int(ceil(remainingAmount / monthly))
            }
        }
        
        let goalDate = monthsToGoal > 0 ? Calendar.current.date(byAdding: .month, value: monthsToGoal, to: Date()) : nil
        
        // Calculate monthly savings needed for different timeframes
        let monthlySavingsFor1Year = remainingAmount / 12
        let monthlySavingsFor2Years = remainingAmount / 24
        let monthlySavingsFor3Years = remainingAmount / 36
        
        // Calculate interest earnings
        let annualInterestEarnings = targetAmount * rate
        
        // Determine recommended months based on expenses
        let recommendedMonths: Double
        if expenses >= 5000 {
            recommendedMonths = 6 // Higher expenses = more stable income likely
        } else if expenses >= 3000 {
            recommendedMonths = 6
        } else {
            recommendedMonths = 3
        }
        
        return EmergencyFundResults(
            targetAmount: targetAmount,
            currentAmount: current,
            remainingAmount: remainingAmount,
            progressPercentage: progressPercentage,
            monthsToGoal: monthsToGoal,
            goalDate: goalDate,
            monthlySavingsFor1Year: monthlySavingsFor1Year,
            monthlySavingsFor2Years: monthlySavingsFor2Years,
            monthlySavingsFor3Years: monthlySavingsFor3Years,
            threeMonthTarget: expenses * 3,
            sixMonthTarget: expenses * 6,
            twelveMonthTarget: expenses * 12,
            recommendedMonths: recommendedMonths,
            annualInterestEarnings: annualInterestEarnings
        )
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private func moveFocusToPrevious() {
        let allFields = EmergencyFundField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .monthlyExpenses) else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : allFields.count - 1
        focusedField = allFields[previousIndex]
    }
    
    private func moveFocusToNext() {
        let allFields = EmergencyFundField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .monthlyExpenses) else { return }
        let nextIndex = currentIndex < allFields.count - 1 ? currentIndex + 1 : 0
        focusedField = allFields[nextIndex]
    }
    
    private func hasPreviousField() -> Bool {
        let allFields = EmergencyFundField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .monthlyExpenses) else { return false }
        return currentIndex > 0
    }
    
    private func hasNextField() -> Bool {
        let allFields = EmergencyFundField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .monthlyExpenses) else { return false }
        return currentIndex < allFields.count - 1
    }
    
    private func fillDemoDataAndCalculate() {
        monthlyExpenses = "4500"
        targetMonths = "6"
        currentSavings = "2000"
        monthlySavings = "500"
        interestRate = "4.5"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        monthlyExpenses = ""
        targetMonths = ""
        currentSavings = ""
        monthlySavings = ""
        interestRate = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let results = calculationResults
        
        let shareText = """
        Emergency Fund Plan:
        
        💰 TARGET FUND: $\(String(format: "%.0f", results.targetAmount))
        📊 Current Progress: \(String(format: "%.1f", results.progressPercentage))%
        💸 Monthly Expenses: $\(monthlyExpenses)
        🎯 Target Coverage: \(targetMonths) months
        
        📈 PROGRESS:
        Current Savings: $\(String(format: "%.0f", results.currentAmount))
        Remaining Needed: $\(String(format: "%.0f", results.remainingAmount))
        
        ⏰ TIMELINE:
        Time to Goal: \(results.monthsToGoal) months
        Monthly Savings: $\(monthlySavings)
        
        💡 RECOMMENDED TARGETS:
        3 months: $\(String(format: "%.0f", results.threeMonthTarget))
        6 months: $\(String(format: "%.0f", results.sixMonthTarget))
        12 months: $\(String(format: "%.0f", results.twelveMonthTarget))
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

struct EmergencyFundResults {
    let targetAmount: Double
    let currentAmount: Double
    let remainingAmount: Double
    let progressPercentage: Double
    let monthsToGoal: Int
    let goalDate: Date?
    let monthlySavingsFor1Year: Double
    let monthlySavingsFor2Years: Double
    let monthlySavingsFor3Years: Double
    let threeMonthTarget: Double
    let sixMonthTarget: Double
    let twelveMonthTarget: Double
    let recommendedMonths: Double
    let annualInterestEarnings: Double
}

struct GuidelineRow: View {
    let title: String
    let description: String
    let amount: Double
    let isRecommended: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if isRecommended {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.0f", amount))")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isRecommended ? .blue : .primary)
        }
        .padding(.vertical, 4)
    }
}

struct EmergencyFundInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Emergency Fund Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Calculates your ideal emergency fund target
                            • Tracks progress toward your savings goal
                            • Shows timeline to reach your target
                            • Provides personalized recommendations
                            """
                        )
                        
                        InfoSection(
                            title: "How Much to Save",
                            content: """
                            • 3 months: Stable job, dual income household
                            • 6 months: Standard recommendation for most people
                            • 9-12 months: Variable income, self-employed, single income
                            • Consider your job security and family situation
                            """
                        )
                        
                        InfoSection(
                            title: "Where to Keep It",
                            content: """
                            • High-yield savings account (4-5% APY)
                            • Money market account with easy access
                            • Short-term CDs if you have other liquid savings
                            • Avoid checking accounts (too low interest)
                            • Avoid stocks (too volatile for emergencies)
                            """
                        )
                        
                        InfoSection(
                            title: "Building Strategy",
                            content: """
                            • Start with $1,000 as initial emergency buffer
                            • Automate savings - set up automatic transfers
                            • Use windfalls: tax refunds, bonuses, gifts
                            • Cut unnecessary expenses temporarily
                            • Consider side income to boost savings rate
                            """
                        )
                        
                        InfoSection(
                            title: "When to Use It",
                            content: """
                            • Job loss or reduced income
                            • Major medical expenses
                            • Essential home or car repairs
                            • NOT for: vacations, shopping, planned purchases
                            • Replenish immediately after using
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Emergency Fund Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}