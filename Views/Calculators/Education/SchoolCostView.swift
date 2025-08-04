import SwiftUI

struct SchoolCostView: View {
    @State private var tuition = ""
    @State private var roomBoard = ""
    @State private var books = ""
    @State private var transportation = ""
    @State private var personal = ""
    @State private var other = ""
    @State private var yearsInSchool = "4"
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: SchoolCostField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum SchoolCostField: CaseIterable {
        case yearsInSchool, tuition, roomBoard, books, transportation, personal, other
    }
    
    var totalAnnualCost: Double {
        let tuitionCost = Double(tuition) ?? 0
        let roomBoardCost = Double(roomBoard) ?? 0
        let booksCost = Double(books) ?? 0
        let transportationCost = Double(transportation) ?? 0
        let personalCost = Double(personal) ?? 0
        let otherCost = Double(other) ?? 0
        
        let costs: [Double] = [
            tuitionCost,
            roomBoardCost,
            booksCost,
            transportationCost,
            personalCost,
            otherCost
        ]
        return costs.reduce(0, +)
    }
    
    var totalDegreeCost: Double {
        guard let years = Double(yearsInSchool), years > 0 else { return totalAnnualCost }
        return totalAnnualCost * years
    }
    
    var monthlyPayment: Double {
        guard let years = Double(yearsInSchool), years > 0 else { return 0 }
        return totalAnnualCost / 12
    }
    
    var costBreakdown: [(category: String, amount: Double, percentage: Double)] {
        let tuitionAmount = Double(tuition) ?? 0
        let roomBoardAmount = Double(roomBoard) ?? 0
        let booksAmount = Double(books) ?? 0
        let transportationAmount = Double(transportation) ?? 0
        let personalAmount = Double(personal) ?? 0
        let otherAmount = Double(other) ?? 0
        
        let items: [(String, Double)] = [
            ("Tuition & Fees", tuitionAmount),
            ("Room & Board", roomBoardAmount),
            ("Books & Supplies", booksAmount),
            ("Transportation", transportationAmount),
            ("Personal Expenses", personalAmount),
            ("Other Costs", otherAmount)
        ]
        
        return items.compactMap { (category, amount) in
            guard amount > 0 else { return nil }
            let percentage = totalAnnualCost > 0 ? (amount / totalAnnualCost) * 100 : 0
            return (category, amount, percentage)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "School Cost", description: "Calculate education expenses") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Duration
                    GroupedInputFields(
                        title: "Program Duration",
                        icon: "calendar.circle.fill",
                        color: .purple
                    ) {
                        CompactInputField(
                            title: "Years in School",
                            value: $yearsInSchool,
                            placeholder: "4",
                            suffix: "years",
                            color: .purple,
                            keyboardType: .numberPad,
                            onNext: { focusNextField(.yearsInSchool) },
                            onDone: { focusedField = nil },
                            showPreviousButton: false
                        )
                        .focused($focusedField, equals: .yearsInSchool)
                        .id(SchoolCostField.yearsInSchool)
                    }
                    
                    // Cost Categories
                    GroupedInputFields(
                        title: "Annual Expenses",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    ) {
                        ModernInputField(
                            title: "Tuition & Fees",
                            value: $tuition,
                            placeholder: "25,000",
                            prefix: "$",
                            icon: "building.columns.fill",
                            color: .blue,
                            keyboardType: .decimalPad,
                            helpText: "Annual tuition, fees, and academic costs",
                            onPrevious: { focusPreviousField(.tuition) },
                            onNext: { focusNextField(.tuition) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .tuition)
                        .id(SchoolCostField.tuition)
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Room & Board",
                                value: $roomBoard,
                                placeholder: "12,000",
                                prefix: "$",
                                color: .orange,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.roomBoard) },
                                onNext: { focusNextField(.roomBoard) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .roomBoard)
                            .id(SchoolCostField.roomBoard)
                            
                            CompactInputField(
                                title: "Books & Supplies",
                                value: $books,
                                placeholder: "1,200",
                                prefix: "$",
                                color: .red,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.books) },
                                onNext: { focusNextField(.books) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .books)
                            .id(SchoolCostField.books)
                        }
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Transportation",
                                value: $transportation,
                                placeholder: "2,000",
                                prefix: "$",
                                color: .indigo,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.transportation) },
                                onNext: { focusNextField(.transportation) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .transportation)
                            .id(SchoolCostField.transportation)
                            
                            CompactInputField(
                                title: "Personal Expenses",
                                value: $personal,
                                placeholder: "1,500",
                                prefix: "$",
                                color: .teal,
                                keyboardType: .decimalPad,
                                onPrevious: { focusPreviousField(.personal) },
                                onNext: { focusNextField(.personal) },
                                onDone: { focusedField = nil }
                            )
                            .focused($focusedField, equals: .personal)
                            .id(SchoolCostField.personal)
                        }
                        
                        CompactInputField(
                            title: "Other Costs",
                            value: $other,
                            placeholder: "500",
                            prefix: "$",
                            color: .brown,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.other) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .other)
                        .id(SchoolCostField.other)
                    }
                    
                    // Calculate Button
                    CalculatorButton(title: "Calculate School Costs") {
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
                    if showResults && totalAnnualCost > 0 {
                        VStack(spacing: 16) {
                            Divider()
                                .id("results")
                        
                        Text("Education Cost Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Results
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Annual Cost",
                                value: NumberFormatter.formatCurrency(totalAnnualCost),
                                color: .blue
                            )
                            
                            CalculatorResultCard(
                                title: "Total Degree Cost",
                                value: NumberFormatter.formatCurrency(totalDegreeCost),
                                subtitle: "\(yearsInSchool) years",
                                color: .purple
                            )
                        }
                        
                        // Monthly Breakdown
                        CalculatorResultCard(
                            title: "Monthly Cost",
                            value: NumberFormatter.formatCurrency(monthlyPayment),
                            subtitle: "Annual cost divided by 12 months",
                            color: .orange
                        )
                        
                        // Cost Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cost Breakdown")
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
                        
                        // Financing Options
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Financing Scenarios")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "If paying cash",
                                    value: NumberFormatter.formatCurrency(totalDegreeCost)
                                )
                                InfoRow(
                                    label: "Student loan (6% APR, 10yr)",
                                    value: "~\(NumberFormatter.formatCurrency(calculateMonthlyPayment(principal: totalDegreeCost, rate: 0.06, years: 10)))/month"
                                )
                                InfoRow(
                                    label: "Parent PLUS loan (7% APR, 10yr)",
                                    value: "~\(NumberFormatter.formatCurrency(calculateMonthlyPayment(principal: totalDegreeCost, rate: 0.07, years: 10)))/month"
                                )
                                InfoRow(
                                    label: "529 Plan savings needed",
                                    value: "~\(NumberFormatter.formatCurrency(totalDegreeCost * 0.8)) (80% coverage)"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Comparison with National Averages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("National Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let publicAverage = 22180.0
                            let privateAverage = 50770.0
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your annual cost",
                                    value: NumberFormatter.formatCurrency(totalAnnualCost)
                                )
                                InfoRow(
                                    label: "Public 4-year average",
                                    value: NumberFormatter.formatCurrency(publicAverage)
                                )
                                InfoRow(
                                    label: "Private 4-year average",
                                    value: NumberFormatter.formatCurrency(privateAverage)
                                )
                            }
                            
                            let comparison = totalAnnualCost < publicAverage ? "below public average" : 
                                           totalAnnualCost < privateAverage ? "above public, below private average" : "above average"
                            
                            Text("Your costs are \(comparison)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Tips for Reducing Costs
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Cost-Saving Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Apply for scholarships and grants early")
                                Text("• Consider community college for first 2 years")
                                Text("• Buy used textbooks or rent them")
                                Text("• Live off-campus or commute to save on room & board")
                                Text("• Take AP courses for college credit")
                                Text("• Look into in-state tuition options")
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
            SchoolCostInfoSheet()
        }
    }
    
    private func calculateMonthlyPayment(principal: Double, rate: Double, years: Double) -> Double {
        let monthlyRate = rate / 12
        let numPayments = years * 12
        
        if monthlyRate == 0 {
            return principal / numPayments
        }
        
        let payment = principal * (monthlyRate * pow(1 + monthlyRate, numPayments)) / (pow(1 + monthlyRate, numPayments) - 1)
        return payment
    }
    
    private func focusNextField(_ currentField: SchoolCostField) {
        let allFields = SchoolCostField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: SchoolCostField) {
        let allFields = SchoolCostField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        yearsInSchool = "4"
        tuition = "25000"
        roomBoard = "12000"
        books = "1200"
        transportation = "2000"
        personal = "1500"
        other = "500"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        yearsInSchool = "4"
        tuition = ""
        roomBoard = ""
        books = ""
        transportation = ""
        personal = ""
        other = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        School Cost Calculator Results:
        Years in School: \(yearsInSchool)
        Annual Cost: \(NumberFormatter.formatCurrency(totalAnnualCost))
        Total Degree Cost: \(NumberFormatter.formatCurrency(totalDegreeCost))
        Monthly Payment: \(NumberFormatter.formatCurrency(monthlyPayment))
        
        Cost Breakdown:
        \(costBreakdown.map { "• \($0.category): \(NumberFormatter.formatCurrency($0.amount))" }.joined(separator: "\n"))
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

struct SchoolCostInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About School Cost Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you estimate the total cost of education by breaking down annual expenses into major categories and projecting the total cost over your academic program."
                        )
                        
                        InfoSection(
                            title: "Cost Categories",
                            content: """
                            • Tuition & Fees: Academic costs charged by the institution
                            • Room & Board: Housing and meal plan expenses
                            • Books & Supplies: Textbooks, materials, and equipment
                            • Transportation: Travel to/from school and local transportation
                            • Personal Expenses: Entertainment, clothing, and miscellaneous costs
                            • Other Costs: Lab fees, technology fees, and additional expenses
                            """
                        )
                        
                        InfoSection(
                            title: "Planning Tips",
                            content: """
                            • Start saving early with a 529 education savings plan
                            • Apply for scholarships and grants to reduce costs
                            • Consider community college for general education requirements
                            • Compare in-state vs. out-of-state tuition options
                            • Factor in potential income loss during school years
                            • Research work-study programs and part-time employment
                            """
                        )
                        
                        InfoSection(
                            title: "Financing Options",
                            content: """
                            • Federal student loans (lower interest rates)
                            • Private student loans (higher rates, credit-based)
                            • Parent PLUS loans (federal loans for parents)
                            • Payment plans offered by the school
                            • Education tax credits and deductions
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("School Cost Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}