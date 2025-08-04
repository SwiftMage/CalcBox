import SwiftUI

struct RentingCostView: View {
    @State private var monthlyRent = ""
    @State private var securityDeposit = ""
    @State private var utilities = ""
    @State private var parking = ""
    @State private var insurance = ""
    @State private var otherFees = ""
    @State private var leaseLength = "12"
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: RentingField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum RentingField: CaseIterable {
        case monthlyRent, securityDeposit, utilities, parking, insurance, otherFees, leaseLength
    }
    
    var totalMonthlyCost: Double {
        let costs: [Double] = [
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
        let baseRent = Double(monthlyRent) ?? 0
        let utilitiesCost = Double(utilities) ?? 0
        let parkingCost = Double(parking) ?? 0
        let insuranceCost = Double(insurance) ?? 0
        let otherFeesCost = Double(otherFees) ?? 0
        
        let items: [(String, Double)] = [
            ("Base Rent", baseRent),
            ("Utilities", utilitiesCost),
            ("Parking", parkingCost),
            ("Insurance", insuranceCost),
            ("Other Fees", otherFeesCost)
        ]
        
        return items.compactMap { (category, amount) in
            guard amount > 0 else { return nil }
            let percentage = totalMonthlyCost > 0 ? (amount / totalMonthlyCost) * 100 : 0
            return (category, amount, percentage)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Renting Cost", description: "Calculate true cost of renting") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Basic Rent
                    GroupedInputFields(
                        title: "Rent Details",
                        icon: "house.fill",
                        color: .blue
                    ) {
                        ModernInputField(
                            title: "Monthly Rent",
                            value: $monthlyRent,
                            placeholder: "1500",
                            prefix: "$",
                            icon: "house.circle.fill",
                            color: .blue,
                            keyboardType: .decimalPad,
                            helpText: "Base monthly rent amount",
                            onNext: { focusNextField(.monthlyRent) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .monthlyRent)
                        .id(RentingField.monthlyRent)
                        
                        ModernInputField(
                            title: "Security Deposit",
                            value: $securityDeposit,
                            placeholder: "1500",
                            prefix: "$",
                            icon: "lock.circle.fill",
                            color: .orange,
                            keyboardType: .decimalPad,
                            helpText: "One-time security deposit (usually 1-2 months rent)",
                            onPrevious: { focusPreviousField(.securityDeposit) },
                            onNext: { focusNextField(.securityDeposit) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .securityDeposit)
                        .id(RentingField.securityDeposit)
                    }
                    
                    // Additional Monthly Costs
                    GroupedInputFields(
                        title: "Additional Monthly Costs",
                        icon: "doc.text.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Utilities (Electric, Gas, Water)",
                            value: $utilities,
                            placeholder: "150",
                            prefix: "$",
                            icon: "bolt.circle.fill",
                            color: .yellow,
                            keyboardType: .decimalPad,
                            helpText: "Monthly utility costs not included in rent",
                            onPrevious: { focusPreviousField(.utilities) },
                            onNext: { focusNextField(.utilities) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .utilities)
                        .id(RentingField.utilities)
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Parking",
                                value: $parking,
                                placeholder: "50",
                                prefix: "$",
                                color: .purple,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.parking) },
                                onNext: { focusNextField(.parking) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .parking)
                            .id(RentingField.parking)
                            
                            CompactInputField(
                                title: "Renter's Insurance",
                                value: $insurance,
                                placeholder: "25",
                                prefix: "$",
                                color: .red,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.insurance) },
                                onNext: { focusNextField(.insurance) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .insurance)
                            .id(RentingField.insurance)
                        }
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Other Fees",
                                value: $otherFees,
                                placeholder: "30",
                                prefix: "$",
                                color: .gray,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.otherFees) },
                                onNext: { focusNextField(.otherFees) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .otherFees)
                            .id(RentingField.otherFees)
                            
                            CompactInputField(
                                title: "Lease Length",
                                value: $leaseLength,
                                placeholder: "12",
                                suffix: "months",
                                color: .blue,
                                keyboardType: .numberPad,
                                onPrevious: { focusPreviousField(.leaseLength) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .leaseLength)
                            .id(RentingField.leaseLength)
                        }
                    }
                
                // Calculate Button
                CalculatorButton(title: "Calculate True Cost") {
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
                if showResults && totalMonthlyCost > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
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
            RentingCostInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: RentingField) {
        let allFields = RentingField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: RentingField) {
        let allFields = RentingField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        monthlyRent = "1500"
        securityDeposit = "1500"
        utilities = "150"
        parking = "50"
        insurance = "25"
        otherFees = "30"
        leaseLength = "12"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        monthlyRent = ""
        securityDeposit = ""
        utilities = ""
        parking = ""
        insurance = ""
        otherFees = ""
        leaseLength = "12"
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Renting Cost Analysis:
        Monthly Rent: \(NumberFormatter.formatCurrency(Double(monthlyRent) ?? 0))
        Total Monthly Cost: \(NumberFormatter.formatCurrency(totalMonthlyCost))
        Total Lease Cost: \(NumberFormatter.formatCurrency(totalLeaseCost))
        Daily Cost: \(NumberFormatter.formatCurrency(dailyCost))
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

struct RentingCostInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Renting Cost Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines the true total cost of renting by including all monthly expenses beyond just the base rent amount."
                        )
                        
                        InfoSection(
                            title: "Cost components",
                            content: """
                            • Monthly rent: Base rental amount
                            • Security deposit: One-time upfront cost
                            • Utilities: Electric, gas, water, internet
                            • Parking: Monthly parking fees
                            • Renter's insurance: Property protection
                            • Other fees: Pet fees, amenities, etc.
                            """
                        )
                        
                        InfoSection(
                            title: "Income guidelines",
                            content: """
                            • 30% Rule: Housing ≤ 30% of gross income
                            • 25% Rule: Conservative approach for better savings
                            • Include all costs, not just base rent
                            • Consider emergency fund for repairs/moves
                            """
                        )
                        
                        InfoSection(
                            title: "Renting tips",
                            content: """
                            • Factor in all costs upfront
                            • Research neighborhood utility costs
                            • Understand what's included in rent
                            • Budget for renter's insurance
                            • Consider commute costs to work
                            • Negotiate lease terms when possible
                            • Plan for annual rent increases
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Renting Cost Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}