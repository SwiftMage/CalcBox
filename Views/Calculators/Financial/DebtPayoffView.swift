import SwiftUI
import Combine

enum DebtPayoffField: CaseIterable {
    case extraPayment
    case debtName
    case balance
    case interestRate
    case minimumPayment
    
    var id: String {
        switch self {
        case .extraPayment: return "extra-payment"
        case .debtName: return "debt-name"
        case .balance: return "balance"
        case .interestRate: return "interest-rate"
        case .minimumPayment: return "minimum-payment"
        }
    }
}

struct Debt: Identifiable {
    let id = UUID()
    var name: String
    var balance: String
    var interestRate: String
    var minimumPayment: String
    
    var balanceValue: Double {
        Double(balance) ?? 0
    }
    
    var interestRateValue: Double {
        Double(interestRate) ?? 0
    }
    
    var minimumPaymentValue: Double {
        Double(minimumPayment) ?? 0
    }
    
    var monthlyInterestRate: Double {
        interestRateValue / 100 / 12
    }
}

struct PayoffResult {
    let method: String
    let totalMonths: Int
    let totalInterest: Double
    let monthlyBreakdown: [MonthlyPayment]
    
    var years: Double {
        Double(totalMonths) / 12.0
    }
}

struct MonthlyPayment {
    let month: Int
    let debtName: String
    let payment: Double
    let principalPayment: Double
    let interestPayment: Double
    let remainingBalance: Double
}

struct DebtPayoffView: View {
    @State private var debts: [Debt] = [
        Debt(name: "Credit Card", balance: "", interestRate: "", minimumPayment: ""),
        Debt(name: "Student Loan", balance: "", interestRate: "", minimumPayment: "")
    ]
    @State private var extraPayment = ""
    @State private var showResults = false
    @State private var showInfo = false
    @State private var snowballResult: PayoffResult?
    @State private var avalancheResult: PayoffResult?
    @State private var selectedTab = 0
    @FocusState private var focusedField: DebtPayoffField?
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Debt Payoff Calculator", description: "Compare debt elimination strategies") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Extra Payment Section
                    GroupedInputFields(title: "Extra Monthly Payment", icon: "plus.circle.fill", color: .green) {
                        ModernInputField(
                            title: "Additional Payment",
                            value: $extraPayment,
                            placeholder: "0.00",
                            prefix: "$",
                            icon: "plus.square.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Extra amount to apply toward debt elimination",
                            onPrevious: { moveFocusToPrevious() },
                            onNext: { moveFocusToNext() },
                            onDone: { focusedField = nil },
                            showPreviousButton: hasPreviousField(),
                            showNextButton: hasNextField()
                        )
                        .focused($focusedField, equals: .extraPayment)
                        .id(DebtPayoffField.extraPayment)
                    }
                    
                    // Debts Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .frame(width: 24)
                                
                                Text("Your Debts")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button("Add Debt") {
                                addNewDebt()
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        ForEach(Array(debts.enumerated()), id: \.1.id) { index, debt in
                            DebtRowView(
                                debt: $debts[index],
                                canDelete: debts.count > 1,
                                onDelete: { removeDebt(at: index) }
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Calculate Button
                    Button(action: {
                        calculatePayoffStrategies()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Calculate Payoff Strategies")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.red, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!canCalculate)
                    
                    if showResults, let snowball = snowballResult, let avalanche = avalancheResult {
                        VStack(spacing: 20) {
                            // Strategy Comparison
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    Text("Strategy Comparison")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 16) {
                                    // Snowball Card
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "snowflake")
                                                .foregroundColor(.blue)
                                            Text("Snowball")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Text("\(String(format: "%.1f", snowball.years)) years")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        
                                        Text("$\(String(format: "%.0f", snowball.totalInterest)) interest")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Avalanche Card
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "flame.fill")
                                                .foregroundColor(.orange)
                                            Text("Avalanche")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Text("\(String(format: "%.1f", avalanche.years)) years")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        
                                        Text("$\(String(format: "%.0f", avalanche.totalInterest)) interest")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Savings with Avalanche
                                if avalanche.totalInterest < snowball.totalInterest {
                                    let savedInterest = snowball.totalInterest - avalanche.totalInterest
                                    let savedMonths = snowball.totalMonths - avalanche.totalMonths
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        
                                        Text("Avalanche saves $\(String(format: "%.0f", savedInterest)) and \(savedMonths) months")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .id("results")
                            
                            // Detailed Results Tabs
                            VStack(spacing: 0) {
                                Picker("Method", selection: $selectedTab) {
                                    Text("Snowball Method").tag(0)
                                    Text("Avalanche Method").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal)
                                
                                TabView(selection: $selectedTab) {
                                    PayoffDetailView(result: snowball, method: "Snowball")
                                        .tag(0)
                                    
                                    PayoffDetailView(result: avalanche, method: "Avalanche")
                                        .tag(1)
                                }
                                .frame(height: 400)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
            DebtPayoffInfoSheet()
        }
    }
    
    private var canCalculate: Bool {
        !extraPayment.isEmpty && debts.allSatisfy { debt in
            !debt.balance.isEmpty && !debt.interestRate.isEmpty && !debt.minimumPayment.isEmpty
        }
    }
    
    private func addNewDebt() {
        debts.append(Debt(name: "New Debt", balance: "", interestRate: "", minimumPayment: ""))
    }
    
    private func removeDebt(at index: Int) {
        if debts.count > 1 {
            debts.remove(at: index)
        }
    }
    
    private func calculatePayoffStrategies() {
        let validDebts = debts.filter { $0.balanceValue > 0 && $0.interestRateValue > 0 && $0.minimumPaymentValue > 0 }
        let extraAmount = Double(extraPayment) ?? 0
        
        // Calculate Snowball (smallest balance first)
        snowballResult = calculateSnowball(debts: validDebts, extraPayment: extraAmount)
        
        // Calculate Avalanche (highest interest rate first)
        avalancheResult = calculateAvalanche(debts: validDebts, extraPayment: extraAmount)
        
        showResults = true
    }
    
    private func calculateSnowball(debts: [Debt], extraPayment: Double) -> PayoffResult {
        var workingDebts = debts.sorted { $0.balanceValue < $1.balanceValue }
        return calculatePayoff(debts: workingDebts, extraPayment: extraPayment, method: "Snowball")
    }
    
    private func calculateAvalanche(debts: [Debt], extraPayment: Double) -> PayoffResult {
        var workingDebts = debts.sorted { $0.interestRateValue > $1.interestRateValue }
        return calculatePayoff(debts: workingDebts, extraPayment: extraPayment, method: "Avalanche")
    }
    
    private func calculatePayoff(debts: [Debt], extraPayment: Double, method: String) -> PayoffResult {
        var workingDebts = debts.map { debt in
            var d = debt
            return d
        }
        
        var month = 0
        var totalInterest = 0.0
        var monthlyBreakdown: [MonthlyPayment] = []
        
        while workingDebts.contains(where: { $0.balanceValue > 0.01 }) {
            month += 1
            var remainingExtra = extraPayment
            
            // Pay minimums on all debts first
            for i in 0..<workingDebts.count {
                if workingDebts[i].balanceValue > 0.01 {
                    let interestPayment = workingDebts[i].balanceValue * workingDebts[i].monthlyInterestRate
                    let principalPayment = min(workingDebts[i].minimumPaymentValue - interestPayment, workingDebts[i].balanceValue)
                    
                    workingDebts[i].balance = String(max(0, workingDebts[i].balanceValue - principalPayment))
                    totalInterest += interestPayment
                    
                    monthlyBreakdown.append(MonthlyPayment(
                        month: month,
                        debtName: workingDebts[i].name,
                        payment: workingDebts[i].minimumPaymentValue,
                        principalPayment: principalPayment,
                        interestPayment: interestPayment,
                        remainingBalance: workingDebts[i].balanceValue
                    ))
                }
            }
            
            // Apply extra payment to first debt with balance
            if let firstDebtIndex = workingDebts.firstIndex(where: { $0.balanceValue > 0.01 }) {
                let extraApplied = min(remainingExtra, workingDebts[firstDebtIndex].balanceValue)
                workingDebts[firstDebtIndex].balance = String(max(0, workingDebts[firstDebtIndex].balanceValue - extraApplied))
            }
            
            // Safety check to prevent infinite loops
            if month > 600 { // 50 years max
                break
            }
        }
        
        return PayoffResult(
            method: method,
            totalMonths: month,
            totalInterest: totalInterest,
            monthlyBreakdown: monthlyBreakdown
        )
    }
    
    private func moveFocusToPrevious() {
        let allFields = DebtPayoffField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .extraPayment) else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : allFields.count - 1
        focusedField = allFields[previousIndex]
    }
    
    private func moveFocusToNext() {
        let allFields = DebtPayoffField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .extraPayment) else { return }
        let nextIndex = currentIndex < allFields.count - 1 ? currentIndex + 1 : 0
        focusedField = allFields[nextIndex]
    }
    
    private func hasPreviousField() -> Bool {
        let allFields = DebtPayoffField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .extraPayment) else { return false }
        return currentIndex > 0
    }
    
    private func hasNextField() -> Bool {
        let allFields = DebtPayoffField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .extraPayment) else { return false }
        return currentIndex < allFields.count - 1
    }
    
    private func fillDemoDataAndCalculate() {
        extraPayment = "200"
        debts = [
            Debt(name: "Credit Card", balance: "5000", interestRate: "18.99", minimumPayment: "125"),
            Debt(name: "Student Loan", balance: "15000", interestRate: "6.5", minimumPayment: "180"),
            Debt(name: "Car Loan", balance: "8000", interestRate: "4.2", minimumPayment: "220")
        ]
        
        calculatePayoffStrategies()
    }
    
    private func clearAllData() {
        extraPayment = ""
        debts = [
            Debt(name: "Credit Card", balance: "", interestRate: "", minimumPayment: ""),
            Debt(name: "Student Loan", balance: "", interestRate: "", minimumPayment: "")
        ]
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        guard let snowball = snowballResult, let avalanche = avalancheResult else { return }
        
        let shareText = """
        Debt Payoff Strategy Comparison:
        
        💳 Total Debts: \(debts.count)
        💰 Extra Payment: $\(extraPayment)/month
        
        📊 Snowball Method:
        Time: \(String(format: "%.1f", snowball.years)) years
        Interest: $\(String(format: "%.0f", snowball.totalInterest))
        
        📈 Avalanche Method:
        Time: \(String(format: "%.1f", avalanche.years)) years
        Interest: $\(String(format: "%.0f", avalanche.totalInterest))
        
        💰 Savings with Avalanche: $\(String(format: "%.0f", snowball.totalInterest - avalanche.totalInterest))
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

struct DebtRowView: View {
    @Binding var debt: Debt
    let canDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Debt Name", text: $debt.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Spacer()
                
                if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    CompactInputField(
                        title: "Balance",
                        value: $debt.balance,
                        placeholder: "0.00",
                        prefix: "$",
                        color: .red
                    )
                    
                    CompactInputField(
                        title: "Interest Rate",
                        value: $debt.interestRate,
                        placeholder: "0.00",
                        suffix: "%",
                        color: .orange
                    )
                }
                
                CompactInputField(
                    title: "Minimum Payment",
                    value: $debt.minimumPayment,
                    placeholder: "0.00",
                    prefix: "$",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct PayoffDetailView: View {
    let result: PayoffResult
    let method: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(method) Method Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Payoff Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(result.totalMonths) months")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Total Interest")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(String(format: "%.0f", result.totalInterest))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Method Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("How it works")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if method == "Snowball" {
                        Text("Pay minimums on all debts, then apply extra payments to the smallest balance first. This method provides psychological wins as you eliminate debts quickly.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Pay minimums on all debts, then apply extra payments to the highest interest rate first. This method is mathematically optimal and saves the most money.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct DebtPayoffInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Debt Payoff Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Compares two proven debt elimination strategies
                            • Shows total time and interest for each method
                            • Calculates savings from choosing optimal strategy
                            • Helps create actionable debt payoff plan
                            """
                        )
                        
                        InfoSection(
                            title: "Snowball Method",
                            content: """
                            • Pay minimums on all debts
                            • Apply extra payment to smallest balance
                            • Provides psychological wins and motivation
                            • Good for people who need encouragement
                            """
                        )
                        
                        InfoSection(
                            title: "Avalanche Method",
                            content: """
                            • Pay minimums on all debts
                            • Apply extra payment to highest interest rate
                            • Mathematically optimal - saves most money
                            • Best for disciplined savers focused on efficiency
                            """
                        )
                        
                        InfoSection(
                            title: "Tips for Success",
                            content: """
                            • Start with any extra amount, even $25/month helps
                            • Consider debt consolidation if rates are high
                            • Stop using credit cards while paying off debt
                            • Set up automatic payments to stay consistent
                            • Celebrate milestones to stay motivated
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Debt Payoff Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}