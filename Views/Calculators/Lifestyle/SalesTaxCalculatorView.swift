import SwiftUI

struct SalesTaxCalculatorView: View {
    @State private var purchaseAmount = ""
    @State private var taxRate = ""
    @State private var calculationType = CalculationType.addTax
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: SalesTaxField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum SalesTaxField: CaseIterable {
        case purchaseAmount, taxRate
    }
    
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
        ScrollViewReader { proxy in
            CalculatorView(title: "Sales Tax", description: "Calculate tax on purchases") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Calculation Type
                    GroupedInputFields(
                        title: "Calculation Type",
                        icon: "plus.forwardslash.minus",
                        color: .purple
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            SegmentedPicker(
                                title: "Type",
                                selection: $calculationType,
                                options: CalculationType.allCases.map { ($0, $0.rawValue) }
                            )
                            
                            Text(calculationType.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Input Fields
                    GroupedInputFields(
                        title: "Amount & Tax Rate",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: calculationType == .addTax ? "Purchase Amount (Pre-tax)" : "Total Amount (With Tax)",
                            value: $purchaseAmount,
                            placeholder: "100.00",
                            prefix: "$",
                            icon: "cart.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: calculationType == .addTax ? "Enter the pre-tax amount" : "Enter the total amount including tax",
                            onNext: { focusNextField(.purchaseAmount) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .purchaseAmount)
                        .id(SalesTaxField.purchaseAmount)
                        
                        CompactInputField(
                            title: "Tax Rate",
                            value: $taxRate,
                            placeholder: "8.25",
                            suffix: "%",
                            color: .orange,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.taxRate) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .taxRate)
                        .id(SalesTaxField.taxRate)
                    }
                    
                    // Common tax rates
                    GroupedInputFields(
                        title: "Common Tax Rates",
                        icon: "percent",
                        color: .blue
                    ) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(["5.0", "6.0", "7.0", "7.5", "8.0", "8.25", "8.5", "9.0", "10.0"], id: \.self) { rate in
                                Button(rate + "%") {
                                    taxRate = rate
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(taxRate == rate ? .white : .blue)
                                .background(taxRate == rate ? Color.blue : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate Tax") {
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
                    if showResults && (Double(purchaseAmount) ?? 0) > 0 {
                        VStack(spacing: 16) {
                            Divider()
                                .id("results")
                        
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
            SalesTaxInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: SalesTaxField) {
        let allFields = SalesTaxField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: SalesTaxField) {
        let allFields = SalesTaxField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        calculationType = .addTax
        purchaseAmount = "100.00"
        taxRate = "8.25"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        purchaseAmount = ""
        taxRate = ""
        calculationType = .addTax
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Sales Tax Calculator Results:
        Calculation Type: \(calculationType.rawValue)
        \(calculationType == .addTax ? "Pre-tax Amount" : "Total Amount"): $\(purchaseAmount)
        Tax Rate: \(taxRate)%
        Tax Amount: \(NumberFormatter.formatCurrency(taxAmount))
        \(calculationType == .addTax ? "Total Amount" : "Pre-tax Amount"): \(calculationType == .addTax ? NumberFormatter.formatCurrency(totalAmount) : NumberFormatter.formatCurrency(preTaxAmount))
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

struct SalesTaxInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Sales Tax Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you determine sales tax amounts for purchases. It can either add tax to a pre-tax amount or calculate the pre-tax amount from a total that includes tax."
                        )
                        
                        InfoSection(
                            title: "Calculation Types",
                            content: """
                            • Add Tax: Calculate tax on pre-tax amount (most common)
                            • Remove Tax: Calculate pre-tax amount from total with tax
                            """
                        )
                        
                        InfoSection(
                            title: "How Sales Tax Works",
                            content: """
                            • Sales tax is a percentage added to the purchase price
                            • Tax rates vary by state, county, and city
                            • Some items may be tax-exempt (groceries, medicine)
                            • Online purchases may require tax depending on location
                            """
                        )
                        
                        InfoSection(
                            title: "Common Tax Rates by State",
                            content: """
                            • No Sales Tax: Alaska, Delaware, Montana, New Hampshire, Oregon
                            • Low Rates (4-6%): Colorado, Georgia, Hawaii, Wyoming
                            • Medium Rates (6-8%): Florida, Texas, Pennsylvania, Ohio
                            • High Rates (8%+): California, New York, Washington, Tennessee
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • Always check local tax rates as they can change
                            • Consider sales tax when budgeting for large purchases
                            • Keep receipts for business expenses and tax deductions
                            • Some states have tax-free shopping days
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Sales Tax Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}