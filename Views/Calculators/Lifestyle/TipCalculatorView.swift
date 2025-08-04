import SwiftUI

struct TipCalculatorView: View {
    @State private var billAmount = ""
    @State private var tipPercentage = "20"
    @State private var numberOfPeople = "1"
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: TipField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum TipField: CaseIterable {
        case billAmount, tipPercentage, numberOfPeople
    }
    
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
        ScrollViewReader { proxy in
            CalculatorView(
                title: "Tip Calculator",
                description: "Calculate tips and split bills"
            ) {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Input Fields
                    GroupedInputFields(
                        title: "Bill Details",
                        icon: "receipt.fill",
                        color: .blue
                    ) {
                        ModernInputField(
                            title: "Bill Amount",
                            value: $billAmount,
                            placeholder: "85.50",
                            prefix: "$",
                            icon: "receipt.circle.fill",
                            color: .green,
                            keyboardType: .decimalPad,
                            helpText: "Total bill amount before tip",
                            onNext: { focusNextField(.billAmount) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .billAmount)
                        .id(TipField.billAmount)
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Tip Percentage",
                                value: $tipPercentage,
                                placeholder: "20",
                                suffix: "%",
                                color: .orange,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.tipPercentage) },
                                onNext: { focusNextField(.tipPercentage) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .tipPercentage)
                            .id(TipField.tipPercentage)
                            
                            CompactInputField(
                                title: "Number of People",
                                value: $numberOfPeople,
                                placeholder: "1",
                                suffix: "people",
                                color: .purple,
                                keyboardType: .numberPad,
                                onPrevious: { focusPreviousField(.numberOfPeople) },
                                onNext: { focusedField = nil },
                                onDone: { focusedField = nil },
                                showNextButton: false
                            )
                            .focused($focusedField, equals: .numberOfPeople)
                            .id(TipField.numberOfPeople)
                        }
                    }
                    
                    // Quick tip percentage buttons
                    GroupedInputFields(
                        title: "Quick Tip Presets",
                        icon: "percent",
                        color: .orange
                    ) {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ForEach(["15", "18", "20"], id: \.self) { percentage in
                                    tipPresetButton(percentage: percentage)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(["22", "25"], id: \.self) { percentage in
                                    tipPresetButton(percentage: percentage)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate Tip") {
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
                    if showResults && totalAmount > 0 {
                        VStack(spacing: 20) {
                            Divider()
                                .id("results")
                            
                            Text("Tip Calculation Results")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Main Results
                            HStack(spacing: 12) {
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
                            
                            // Per Person Breakdown
                            if let people = Double(numberOfPeople), people > 1 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Per Person Breakdown")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(spacing: 8) {
                                        InfoRow(
                                            label: "Total per person",
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
                            
                            // Bill Summary
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Bill Summary")
                                    .font(.headline)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Original Bill",
                                        value: NumberFormatter.formatCurrency(Double(billAmount) ?? 0)
                                    )
                                    InfoRow(
                                        label: "Tip (\(tipPercentage)%)",
                                        value: NumberFormatter.formatCurrency(totalTip)
                                    )
                                    Divider()
                                    InfoRow(
                                        label: "Grand Total",
                                        value: NumberFormatter.formatCurrency(totalAmount)
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
            TipInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: TipField) {
        let allFields = TipField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: TipField) {
        let allFields = TipField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        billAmount = "85.50"
        tipPercentage = "20"
        numberOfPeople = "4"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        billAmount = ""
        tipPercentage = "20"
        numberOfPeople = "1"
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Tip Calculation Results:
        Bill Amount: $\(billAmount)
        Tip (\(tipPercentage)%): \(NumberFormatter.formatCurrency(totalTip))
        Total Amount: \(NumberFormatter.formatCurrency(totalAmount))
        \(numberOfPeople != "1" ? "Per Person: \(NumberFormatter.formatCurrency(amountPerPerson))" : "")
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
    
    private func tipPresetButton(percentage: String) -> some View {
        Button(percentage + "%") {
            tipPercentage = percentage
        }
        .buttonStyle(.bordered)
        .foregroundColor(tipPercentage == percentage ? .white : .orange)
        .background(tipPercentage == percentage ? Color.orange : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TipInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Tip Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you determine the appropriate tip amount and split bills among multiple people."
                        )
                        
                        InfoSection(
                            title: "Tip Guidelines",
                            content: """
                            • 15%: Acceptable service
                            • 18-20%: Good service (standard)
                            • 22-25%: Excellent service
                            • Consider service quality and local customs
                            """
                        )
                        
                        InfoSection(
                            title: "Bill Splitting",
                            content: """
                            • Enter the number of people sharing the bill
                            • Tip is calculated on the total before splitting
                            • Each person pays their share including tip
                            """
                        )
                        
                        InfoSection(
                            title: "Tips for Tipping",
                            content: """
                            • Tip on pre-tax amount when possible
                            • Round up to nearest dollar for convenience
                            • Consider cash tips for better service
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Tip Calculator Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}