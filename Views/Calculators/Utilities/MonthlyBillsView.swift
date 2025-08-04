import SwiftUI

struct MonthlyBillsView: View {
    @State private var bills: [BillItem] = [BillItem()]
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: BillField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum BillField: Hashable {
        case billName(UUID)
        case billAmount(UUID)
    }
    
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
        BillCategory.allCases.compactMap { category in
            let categoryBills = bills.filter { $0.category == category && !$0.amount.isEmpty && !$0.name.isEmpty }
            let total = categoryBills.compactMap { bill in
                guard let amount = Double(bill.amount) else { return nil }
                return amount * bill.frequency.monthlyMultiplier
            }.reduce(0.0) { $0 + $1 }
            
            return total > 0 ? (category, total) : nil
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Monthly Bills", description: "Track recurring expenses") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
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
                            VStack(spacing: 12) {
                                HStack {
                                    ModernInputField(
                                        title: "Bill Name",
                                        value: $bills[index].name,
                                        placeholder: "Electric Bill",
                                        icon: "doc.text.fill",
                                        color: bills[index].category.color,
                                        keyboardType: .default,
                                        helpText: "Name of the bill or service",
                                        onNext: { 
                                            focusedField = .billAmount(bills[index].id)
                                        },
                                        onDone: { focusedField = nil },
                                        showPreviousButton: false
                                    )
                                    .focused($focusedField, equals: .billName(bills[index].id))
                                    
                                    Button {
                                        if bills.count > 1 {
                                            bills.remove(at: index)
                                        }
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
                                        
                                        Picker("Category", selection: $bills[index].category) {
                                            ForEach(BillCategory.allCases, id: \.self) { category in
                                                Text(category.rawValue).tag(category)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(maxWidth: .infinity)
                                    }
                                    
                                    CompactInputField(
                                        title: "Amount",
                                        value: $bills[index].amount,
                                        placeholder: "100",
                                        prefix: "$",
                                        color: bills[index].category.color,
                                        keyboardType: .decimalPad,
                                        onPrevious: {
                                            focusedField = .billName(bills[index].id)
                                        },
                                        onNext: { focusedField = nil },
                                        onDone: { focusedField = nil },
                                        showNextButton: false
                                    )
                                    .focused($focusedField, equals: .billAmount(bills[index].id))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Frequency")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Picker("Frequency", selection: $bills[index].frequency) {
                                            ForEach(BillFrequency.allCases, id: \.self) { frequency in
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(bills[index].category.color.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .id("bill-\(bills[index].id)")
                        }
                    }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Monthly Total") {
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
                if showResults && totalMonthlyBills > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
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
                        
                        // Income Guidelines
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
                .padding(.bottom, keyboardHeight)
            }
            .onChange(of: focusedField) { field in
                if let field = field {
                    let billId: UUID
                    switch field {
                    case .billName(let id), .billAmount(let id):
                        billId = id
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("bill-\(billId)", anchor: .center)
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
            MonthlyBillsInfoSheet()
        }
    }
    
    private func fillDemoDataAndCalculate() {
        bills = [
            BillItem(name: "Rent", amount: "1200", category: .housing, frequency: .monthly),
            BillItem(name: "Electric", amount: "85", category: .utilities, frequency: .monthly),
            BillItem(name: "Internet", amount: "60", category: .utilities, frequency: .monthly),
            BillItem(name: "Car Insurance", amount: "150", category: .insurance, frequency: .monthly),
            BillItem(name: "Netflix", amount: "15", category: .subscriptions, frequency: .monthly)
        ]
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        bills = [BillItem()]
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Monthly Bills Summary:
        Total Monthly Bills: \(NumberFormatter.formatCurrency(totalMonthlyBills))
        Annual Total: \(NumberFormatter.formatCurrency(totalMonthlyBills * 12))
        
        By Category:
        \(billsByCategory.map { "\($0.category.rawValue): \(NumberFormatter.formatCurrency($0.total))" }.joined(separator: "\n"))
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


struct MonthlyBillsInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Monthly Bills Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you track all your recurring monthly expenses and see your total financial obligations broken down by category."
                        )
                        
                        InfoSection(
                            title: "Bill categories",
                            content: """
                            • Housing: Rent, mortgage, property taxes
                            • Utilities: Electric, gas, water, internet
                            • Transportation: Car payments, gas, maintenance
                            • Insurance: Health, auto, home, life
                            • Subscriptions: Streaming, software, memberships
                            • Debt: Credit cards, loans, student loans
                            """
                        )
                        
                        InfoSection(
                            title: "Frequency options",
                            content: """
                            • Weekly: Multiplied by 4.33 for monthly equivalent
                            • Bi-weekly: Multiplied by 2.17 for monthly equivalent
                            • Monthly: Used as-is
                            • Quarterly: Divided by 3 for monthly equivalent
                            • Annually: Divided by 12 for monthly equivalent
                            """
                        )
                        
                        InfoSection(
                            title: "Money-saving tips",
                            content: """
                            • Review and cancel unused subscriptions
                            • Bundle services for discounts
                            • Set up autopay for bill discounts
                            • Compare providers annually
                            • Negotiate bills when possible
                            • Track usage to avoid overpaying
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Monthly Bills Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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