import SwiftUI
import Combine

enum LeaseVsBuyField: CaseIterable {
    case carPrice
    case downPaymentBuy
    case loanRate
    case loanTerm
    case monthlyLease
    case downPaymentLease
    case leaseTerm
    case residualValue
    case milesPerYear
    case maintenanceBuy
    case maintenanceLease
    
    var id: String {
        switch self {
        case .carPrice: return "car-price"
        case .downPaymentBuy: return "down-payment-buy"
        case .loanRate: return "loan-rate"
        case .loanTerm: return "loan-term"
        case .monthlyLease: return "monthly-lease"
        case .downPaymentLease: return "down-payment-lease"
        case .leaseTerm: return "lease-term"
        case .residualValue: return "residual-value"
        case .milesPerYear: return "miles-per-year"
        case .maintenanceBuy: return "maintenance-buy"
        case .maintenanceLease: return "maintenance-lease"
        }
    }
}

struct LeaseVsBuyView: View {
    // Car Details
    @State private var carPrice = ""
    @State private var milesPerYear = ""
    
    // Buying Option
    @State private var downPaymentBuy = ""
    @State private var loanRate = ""
    @State private var loanTerm = ""
    @State private var maintenanceBuy = ""
    
    // Leasing Option
    @State private var monthlyLease = ""
    @State private var downPaymentLease = ""
    @State private var leaseTerm = ""
    @State private var residualValue = ""
    @State private var maintenanceLease = ""
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: LeaseVsBuyField?
    @State private var keyboardHeight: CGFloat = 0
    
    // Calculated Results
    private var buyingResults: BuyingResults {
        calculateBuyingCosts()
    }
    
    private var leasingResults: LeasingResults {
        calculateLeasingCosts()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Lease vs Buy Calculator", description: "Compare car leasing vs buying costs") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Car Details
                    GroupedInputFields(title: "Vehicle Details", icon: "car.fill", color: .blue) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Car Price (MSRP)",
                                value: $carPrice,
                                placeholder: "30000",
                                prefix: "$",
                                icon: "car.fill",
                                color: .blue,
                                keyboardType: .decimalPad,
                                helpText: "Manufacturer's suggested retail price",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .carPrice)
                            .id(LeaseVsBuyField.carPrice)
                            
                            ModernInputField(
                                title: "Miles Per Year",
                                value: $milesPerYear,
                                placeholder: "12000",
                                icon: "speedometer",
                                color: .blue,
                                keyboardType: .decimalPad,
                                helpText: "Your estimated annual mileage",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .milesPerYear)
                            .id(LeaseVsBuyField.milesPerYear)
                        }
                    }
                    
                    // Buying Option
                    GroupedInputFields(title: "Buying Option", icon: "creditcard.fill", color: .green) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Down Payment",
                                value: $downPaymentBuy,
                                placeholder: "5000",
                                prefix: "$",
                                icon: "banknote.fill",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Initial payment when buying",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .downPaymentBuy)
                            .id(LeaseVsBuyField.downPaymentBuy)
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Loan Interest Rate",
                                    value: $loanRate,
                                    placeholder: "6.5",
                                    suffix: "%",
                                    icon: "percent",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .loanRate)
                                .id(LeaseVsBuyField.loanRate)
                                
                                ModernInputField(
                                    title: "Loan Term",
                                    value: $loanTerm,
                                    placeholder: "60",
                                    suffix: "months",
                                    icon: "calendar",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .loanTerm)
                                .id(LeaseVsBuyField.loanTerm)
                            }
                            
                            ModernInputField(
                                title: "Monthly Maintenance",
                                value: $maintenanceBuy,
                                placeholder: "150",
                                prefix: "$",
                                icon: "wrench.fill",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Average monthly maintenance/repair costs",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .maintenanceBuy)
                            .id(LeaseVsBuyField.maintenanceBuy)
                        }
                    }
                    
                    // Leasing Option
                    GroupedInputFields(title: "Leasing Option", icon: "doc.text.fill", color: .orange) {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Monthly Lease Payment",
                                    value: $monthlyLease,
                                    placeholder: "399",
                                    prefix: "$",
                                    icon: "calendar.badge.clock",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .monthlyLease)
                                .id(LeaseVsBuyField.monthlyLease)
                                
                                ModernInputField(
                                    title: "Lease Term",
                                    value: $leaseTerm,
                                    placeholder: "36",
                                    suffix: "months",
                                    icon: "calendar",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .leaseTerm)
                                .id(LeaseVsBuyField.leaseTerm)
                            }
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Down Payment",
                                    value: $downPaymentLease,
                                    placeholder: "2000",
                                    prefix: "$",
                                    icon: "banknote.fill",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .downPaymentLease)
                                .id(LeaseVsBuyField.downPaymentLease)
                                
                                ModernInputField(
                                    title: "Residual Value",
                                    value: $residualValue,
                                    placeholder: "18000",
                                    prefix: "$",
                                    icon: "chart.line.downtrend.xyaxis",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .residualValue)
                                .id(LeaseVsBuyField.residualValue)
                            }
                            
                            ModernInputField(
                                title: "Monthly Maintenance",
                                value: $maintenanceLease,
                                placeholder: "50",
                                prefix: "$",
                                icon: "wrench.fill",
                                color: .orange,
                                keyboardType: .decimalPad,
                                helpText: "Usually lower due to warranty coverage",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .maintenanceLease)
                            .id(LeaseVsBuyField.maintenanceLease)
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
                            Image(systemName: "chart.bar.fill")
                            Text("Compare Lease vs Buy")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!canCalculate)
                    
                    if showResults && canCalculate {
                        VStack(spacing: 20) {
                            // Comparison Cards
                            HStack(spacing: 16) {
                                // Buying Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "creditcard.fill")
                                            .foregroundColor(.green)
                                        Text("Buying")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Total Cost:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", buyingResults.totalCost))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Monthly Payment:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", buyingResults.monthlyPayment))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Car Value:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", buyingResults.finalValue))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                // Leasing Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "doc.text.fill")
                                            .foregroundColor(.orange)
                                        Text("Leasing")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Total Cost:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", leasingResults.totalCost))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Monthly Payment:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", leasingResults.monthlyPayment))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Car Value:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$0")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .id("results")
                            
                            // Recommendation
                            let recommendation = getRecommendation()
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: recommendation.icon)
                                        .foregroundColor(recommendation.color)
                                        .font(.title2)
                                    
                                    Text("Recommendation")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                Text(recommendation.message)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(recommendation.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Detailed Breakdown
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "list.bullet.clipboard")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    Text("Cost Breakdown")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 12) {
                                    CostBreakdownRow(label: "Buying - Down Payment", amount: buyingResults.downPayment)
                                    CostBreakdownRow(label: "Buying - Total Interest", amount: buyingResults.totalInterest)
                                    CostBreakdownRow(label: "Buying - Maintenance", amount: buyingResults.totalMaintenance)
                                    
                                    Divider()
                                    
                                    CostBreakdownRow(label: "Leasing - Down Payment", amount: leasingResults.downPayment)
                                    CostBreakdownRow(label: "Leasing - Total Payments", amount: leasingResults.totalPayments)
                                    CostBreakdownRow(label: "Leasing - Maintenance", amount: leasingResults.totalMaintenance)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
            LeaseVsBuyInfoSheet()
        }
    }
    
    private var canCalculate: Bool {
        !carPrice.isEmpty && !downPaymentBuy.isEmpty && !loanRate.isEmpty && 
        !loanTerm.isEmpty && !monthlyLease.isEmpty && !leaseTerm.isEmpty
    }
    
    private func calculateBuyingCosts() -> BuyingResults {
        let price = Double(carPrice) ?? 0
        let down = Double(downPaymentBuy) ?? 0
        let rate = (Double(loanRate) ?? 0) / 100 / 12
        let term = Double(loanTerm) ?? 0
        let maintenance = Double(maintenanceBuy) ?? 0
        
        let loanAmount = price - down
        let monthlyPayment = rate > 0 ? 
            loanAmount * (rate * pow(1 + rate, term)) / (pow(1 + rate, term) - 1) : 
            loanAmount / term
        
        let totalPayments = monthlyPayment * term
        let totalInterest = totalPayments - loanAmount
        let totalMaintenance = maintenance * term
        
        // Estimated car value after loan term (rough depreciation)
        let yearsOwned = term / 12
        let depreciationRate = 0.15 // 15% per year average
        let finalValue = price * pow(1 - depreciationRate, yearsOwned)
        
        return BuyingResults(
            monthlyPayment: monthlyPayment,
            downPayment: down,
            totalInterest: totalInterest,
            totalMaintenance: totalMaintenance,
            finalValue: max(0, finalValue),
            totalCost: down + totalPayments + totalMaintenance
        )
    }
    
    private func calculateLeasingCosts() -> LeasingResults {
        let monthly = Double(monthlyLease) ?? 0
        let down = Double(downPaymentLease) ?? 0
        let term = Double(leaseTerm) ?? 0
        let maintenance = Double(maintenanceLease) ?? 0
        
        let totalPayments = monthly * term
        let totalMaintenance = maintenance * term
        
        return LeasingResults(
            monthlyPayment: monthly,
            downPayment: down,
            totalPayments: totalPayments,
            totalMaintenance: totalMaintenance,
            totalCost: down + totalPayments + totalMaintenance
        )
    }
    
    private func getRecommendation() -> Recommendation {
        let buyingNet = buyingResults.totalCost - buyingResults.finalValue
        let leasingNet = leasingResults.totalCost
        
        if buyingNet < leasingNet {
            let savings = leasingNet - buyingNet
            return Recommendation(
                message: "Buying is better! You'll save $\(String(format: "%.0f", savings)) over \(leaseTerm) months and own an asset worth $\(String(format: "%.0f", buyingResults.finalValue)).",
                color: .green,
                icon: "checkmark.circle.fill"
            )
        } else {
            let savings = buyingNet - leasingNet
            return Recommendation(
                message: "Leasing is better! You'll save $\(String(format: "%.0f", savings)) over \(leaseTerm) months with lower monthly payments and warranty coverage.",
                color: .orange,
                icon: "doc.checkmark.fill"
            )
        }
    }
    
    private func moveFocusToPrevious() {
        let allFields = LeaseVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .carPrice) else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : allFields.count - 1
        focusedField = allFields[previousIndex]
    }
    
    private func moveFocusToNext() {
        let allFields = LeaseVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .carPrice) else { return }
        let nextIndex = currentIndex < allFields.count - 1 ? currentIndex + 1 : 0
        focusedField = allFields[nextIndex]
    }
    
    private func hasPreviousField() -> Bool {
        let allFields = LeaseVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .carPrice) else { return false }
        return currentIndex > 0
    }
    
    private func hasNextField() -> Bool {
        let allFields = LeaseVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .carPrice) else { return false }
        return currentIndex < allFields.count - 1
    }
    
    private func fillDemoDataAndCalculate() {
        carPrice = "30000"
        milesPerYear = "12000"
        downPaymentBuy = "5000"
        loanRate = "6.5"
        loanTerm = "60"
        maintenanceBuy = "150"
        monthlyLease = "399"
        downPaymentLease = "2000"
        leaseTerm = "36"
        residualValue = "18000"
        maintenanceLease = "50"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        carPrice = ""
        milesPerYear = ""
        downPaymentBuy = ""
        loanRate = ""
        loanTerm = ""
        maintenanceBuy = ""
        monthlyLease = ""
        downPaymentLease = ""
        leaseTerm = ""
        residualValue = ""
        maintenanceLease = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Car Lease vs Buy Analysis:
        
        🚗 Vehicle: $\(carPrice) MSRP
        📊 Analysis Period: \(leaseTerm) months
        
        💰 BUYING OPTION:
        Down Payment: $\(downPaymentBuy)
        Monthly Payment: $\(String(format: "%.0f", buyingResults.monthlyPayment))
        Total Cost: $\(String(format: "%.0f", buyingResults.totalCost))
        Final Car Value: $\(String(format: "%.0f", buyingResults.finalValue))
        
        📄 LEASING OPTION:
        Down Payment: $\(downPaymentLease)
        Monthly Payment: $\(monthlyLease)
        Total Cost: $\(String(format: "%.0f", leasingResults.totalCost))
        Final Car Value: $0
        
        🎯 Net Cost Comparison:
        Buying: $\(String(format: "%.0f", buyingResults.totalCost - buyingResults.finalValue))
        Leasing: $\(String(format: "%.0f", leasingResults.totalCost))
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

struct BuyingResults {
    let monthlyPayment: Double
    let downPayment: Double
    let totalInterest: Double
    let totalMaintenance: Double
    let finalValue: Double
    let totalCost: Double
}

struct LeasingResults {
    let monthlyPayment: Double
    let downPayment: Double
    let totalPayments: Double
    let totalMaintenance: Double
    let totalCost: Double
}

struct Recommendation {
    let message: String
    let color: Color
    let icon: String
}

struct CostBreakdownRow: View {
    let label: String
    let amount: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text("$\(String(format: "%.0f", amount))")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct LeaseVsBuyInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Lease vs Buy Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Compares total cost of leasing vs buying
                            • Factors in loan interest, maintenance, and depreciation
                            • Shows monthly payment differences
                            • Calculates net cost after car value
                            """
                        )
                        
                        InfoSection(
                            title: "When to Buy",
                            content: """
                            • You drive more than 15,000 miles/year
                            • You want to build equity and own an asset
                            • You plan to keep the car for many years
                            • You don't mind maintenance after warranty
                            """
                        )
                        
                        InfoSection(
                            title: "When to Lease",
                            content: """
                            • You want lower monthly payments
                            • You like driving newer cars with latest features
                            • You drive less than 12,000-15,000 miles/year
                            • You want warranty coverage throughout
                            """
                        )
                        
                        InfoSection(
                            title: "Important Considerations",
                            content: """
                            • Lease mileage restrictions and excess charges
                            • Wear and tear charges when returning lease
                            • Gap insurance needs for both options
                            • Tax implications may vary by state
                            • Early termination fees for leases
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Lease vs Buy Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}