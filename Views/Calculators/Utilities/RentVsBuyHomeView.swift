import SwiftUI
import Combine

enum RentVsBuyField: CaseIterable {
    case homePrice
    case downPayment
    case mortgageRate
    case mortgageTerm
    case propertyTax
    case homeInsurance
    case pmi
    case hoaFees
    case maintenance
    case monthlyRent
    case rentIncrease
    case rentersInsurance
    case yearsToAnalyze
    
    var id: String {
        switch self {
        case .homePrice: return "home-price"
        case .downPayment: return "down-payment"
        case .mortgageRate: return "mortgage-rate"
        case .mortgageTerm: return "mortgage-term"
        case .propertyTax: return "property-tax"
        case .homeInsurance: return "home-insurance"
        case .pmi: return "pmi"
        case .hoaFees: return "hoa-fees"
        case .maintenance: return "maintenance"
        case .monthlyRent: return "monthly-rent"
        case .rentIncrease: return "rent-increase"
        case .rentersInsurance: return "renters-insurance"
        case .yearsToAnalyze: return "years-to-analyze"
        }
    }
}

struct RentVsBuyHomeView: View {
    // Home Purchase Details
    @State private var homePrice = ""
    @State private var downPayment = ""
    @State private var mortgageRate = ""
    @State private var mortgageTerm = ""
    @State private var propertyTax = ""
    @State private var homeInsurance = ""
    @State private var pmi = ""
    @State private var hoaFees = ""
    @State private var maintenance = ""
    
    // Rental Details
    @State private var monthlyRent = ""
    @State private var rentIncrease = ""
    @State private var rentersInsurance = ""
    
    // Analysis Period
    @State private var yearsToAnalyze = ""
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: RentVsBuyField?
    @State private var keyboardHeight: CGFloat = 0
    
    // Calculated Results
    private var buyingResults: HomeBuyingResults {
        calculateBuyingCosts()
    }
    
    private var rentingResults: RentingResults {
        calculateRentingCosts()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Rent vs Buy Home", description: "Compare renting vs buying a home") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Analysis Period
                    GroupedInputFields(title: "Analysis Period", icon: "calendar.badge.clock", color: .blue) {
                        ModernInputField(
                            title: "Years to Analyze",
                            value: $yearsToAnalyze,
                            placeholder: "5",
                            suffix: "years",
                            icon: "clock.fill",
                            color: .blue,
                            keyboardType: .decimalPad,
                            helpText: "How long do you plan to stay?",
                            onPrevious: { moveFocusToPrevious() },
                            onNext: { moveFocusToNext() },
                            onDone: { focusedField = nil },
                            showPreviousButton: hasPreviousField(),
                            showNextButton: hasNextField()
                        )
                        .focused($focusedField, equals: .yearsToAnalyze)
                        .id(RentVsBuyField.yearsToAnalyze)
                    }
                    
                    // Home Purchase Details
                    GroupedInputFields(title: "Buying Option", icon: "house.fill", color: .green) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Home Price",
                                value: $homePrice,
                                placeholder: "400000",
                                prefix: "$",
                                icon: "house.fill",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Purchase price of the home",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .homePrice)
                            .id(RentVsBuyField.homePrice)
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Down Payment",
                                    value: $downPayment,
                                    placeholder: "80000",
                                    prefix: "$",
                                    icon: "banknote.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .downPayment)
                                .id(RentVsBuyField.downPayment)
                                
                                ModernInputField(
                                    title: "Mortgage Rate",
                                    value: $mortgageRate,
                                    placeholder: "7.0",
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
                                .focused($focusedField, equals: .mortgageRate)
                                .id(RentVsBuyField.mortgageRate)
                            }
                            
                            ModernInputField(
                                title: "Mortgage Term",
                                value: $mortgageTerm,
                                placeholder: "30",
                                suffix: "years",
                                icon: "calendar",
                                color: .green,
                                keyboardType: .decimalPad,
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .mortgageTerm)
                            .id(RentVsBuyField.mortgageTerm)
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Property Tax",
                                    value: $propertyTax,
                                    placeholder: "500",
                                    prefix: "$",
                                    suffix: "/mo",
                                    icon: "building.2.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .propertyTax)
                                .id(RentVsBuyField.propertyTax)
                                
                                ModernInputField(
                                    title: "Home Insurance",
                                    value: $homeInsurance,
                                    placeholder: "150",
                                    prefix: "$",
                                    suffix: "/mo",
                                    icon: "shield.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .homeInsurance)
                                .id(RentVsBuyField.homeInsurance)
                            }
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "PMI",
                                    value: $pmi,
                                    placeholder: "200",
                                    prefix: "$",
                                    suffix: "/mo",
                                    icon: "plus.circle.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .pmi)
                                .id(RentVsBuyField.pmi)
                                
                                ModernInputField(
                                    title: "HOA Fees",
                                    value: $hoaFees,
                                    placeholder: "0",
                                    prefix: "$",
                                    suffix: "/mo",
                                    icon: "building.columns.fill",
                                    color: .green,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .hoaFees)
                                .id(RentVsBuyField.hoaFees)
                            }
                            
                            ModernInputField(
                                title: "Maintenance & Repairs",
                                value: $maintenance,
                                placeholder: "300",
                                prefix: "$",
                                suffix: "/mo",
                                icon: "wrench.fill",
                                color: .green,
                                keyboardType: .decimalPad,
                                helpText: "Average monthly maintenance costs",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .maintenance)
                            .id(RentVsBuyField.maintenance)
                        }
                    }
                    
                    // Rental Option
                    GroupedInputFields(title: "Renting Option", icon: "key.fill", color: .orange) {
                        VStack(spacing: 16) {
                            ModernInputField(
                                title: "Monthly Rent",
                                value: $monthlyRent,
                                placeholder: "2500",
                                prefix: "$",
                                icon: "key.fill",
                                color: .orange,
                                keyboardType: .decimalPad,
                                helpText: "Current monthly rent payment",
                                onPrevious: { moveFocusToPrevious() },
                                onNext: { moveFocusToNext() },
                                onDone: { focusedField = nil },
                                showPreviousButton: hasPreviousField(),
                                showNextButton: hasNextField()
                            )
                            .focused($focusedField, equals: .monthlyRent)
                            .id(RentVsBuyField.monthlyRent)
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Annual Rent Increase",
                                    value: $rentIncrease,
                                    placeholder: "3.0",
                                    suffix: "%",
                                    icon: "arrow.up.circle.fill",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .rentIncrease)
                                .id(RentVsBuyField.rentIncrease)
                                
                                ModernInputField(
                                    title: "Renters Insurance",
                                    value: $rentersInsurance,
                                    placeholder: "25",
                                    prefix: "$",
                                    suffix: "/mo",
                                    icon: "shield.fill",
                                    color: .orange,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .rentersInsurance)
                                .id(RentVsBuyField.rentersInsurance)
                            }
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
                            Text("Compare Rent vs Buy")
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
                            // Summary Comparison
                            HStack(spacing: 16) {
                                // Buying Summary
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "house.fill")
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
                                            Text("$\(String(format: "%.0f", buyingResults.totalMonthlyPayment))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Home Equity:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", buyingResults.finalEquity))")
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
                                
                                // Renting Summary
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(.orange)
                                        Text("Renting")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Total Cost:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", rentingResults.totalCost))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Avg Monthly:")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("$\(String(format: "%.0f", rentingResults.averageMonthlyPayment))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        HStack {
                                            Text("Equity Built:")
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
                            
                            // Net Worth Comparison
                            let netBuying = buyingResults.finalEquity - buyingResults.totalCost
                            let netRenting = -rentingResults.totalCost
                            let netDifference = netBuying - netRenting
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: netDifference > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundColor(netDifference > 0 ? .green : .orange)
                                        .font(.title2)
                                    
                                    Text("Net Worth Impact")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                if netDifference > 0 {
                                    Text("Buying is better! After \(yearsToAnalyze) years, you'll be $\(String(format: "%.0f", netDifference)) ahead by building equity instead of paying rent.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Text("Renting is better! You'll save $\(String(format: "%.0f", abs(netDifference))) over \(yearsToAnalyze) years with lower total costs and more flexibility.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding()
                            .background((netDifference > 0 ? Color.green : Color.orange).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Break-Even Analysis
                            let breakEvenYears = calculateBreakEvenPoint()
                            if breakEvenYears > 0 {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                        
                                        Text("Break-Even Point")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Buying becomes financially better after approximately \(String(format: "%.1f", breakEvenYears)) years. This is when the equity built exceeds the extra costs of ownership.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            // Detailed Cost Breakdown
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
                                    Text("BUYING COSTS")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                    
                                    HomeCostRow(label: "Down Payment", amount: buyingResults.downPaymentAmount)
                                    HomeCostRow(label: "Monthly Mortgage P&I", amount: buyingResults.monthlyMortgage)
                                    HomeCostRow(label: "Property Tax", amount: buyingResults.monthlyPropertyTax)
                                    HomeCostRow(label: "Home Insurance", amount: buyingResults.monthlyInsurance)
                                    HomeCostRow(label: "PMI", amount: buyingResults.monthlyPMI)
                                    HomeCostRow(label: "Maintenance", amount: buyingResults.monthlyMaintenance)
                                    
                                    Divider()
                                    
                                    Text("RENTING COSTS")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                    
                                    HomeCostRow(label: "Starting Monthly Rent", amount: rentingResults.initialRent)
                                    HomeCostRow(label: "Final Monthly Rent", amount: rentingResults.finalRent)
                                    HomeCostRow(label: "Renters Insurance", amount: rentingResults.monthlyInsurance)
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
            RentVsBuyHomeInfoSheet()
        }
    }
    
    private var canCalculate: Bool {
        !homePrice.isEmpty && !downPayment.isEmpty && !mortgageRate.isEmpty && 
        !monthlyRent.isEmpty && !yearsToAnalyze.isEmpty
    }
    
    private func calculateBuyingCosts() -> HomeBuyingResults {
        let price = Double(homePrice) ?? 0
        let down = Double(downPayment) ?? 0
        let rate = (Double(mortgageRate) ?? 0) / 100 / 12
        let term = (Double(mortgageTerm) ?? 30) * 12
        let propTax = Double(propertyTax) ?? 0
        let insurance = Double(homeInsurance) ?? 0
        let pmiAmount = Double(pmi) ?? 0
        let hoa = Double(hoaFees) ?? 0
        let maintenanceAmount = Double(maintenance) ?? 0
        let years = Double(yearsToAnalyze) ?? 5
        
        let loanAmount = price - down
        let monthlyMortgage = rate > 0 ? 
            loanAmount * (rate * pow(1 + rate, term)) / (pow(1 + rate, term) - 1) : 
            loanAmount / term
        
        let totalMonthlyPayment = monthlyMortgage + propTax + insurance + pmiAmount + hoa + maintenanceAmount
        let totalPayments = totalMonthlyPayment * years * 12
        
        // Calculate equity built (principal payments + appreciation)
        let principalPaid = calculatePrincipalPaid(loanAmount: loanAmount, rate: rate, term: term, years: years)
        let homeAppreciation = price * 0.03 * years // 3% annual appreciation
        let finalEquity = down + principalPaid + homeAppreciation
        
        return HomeBuyingResults(
            monthlyMortgage: monthlyMortgage,
            monthlyPropertyTax: propTax,
            monthlyInsurance: insurance,
            monthlyPMI: pmiAmount,
            monthlyMaintenance: maintenanceAmount,
            totalMonthlyPayment: totalMonthlyPayment,
            downPaymentAmount: down,
            totalCost: totalPayments,
            finalEquity: finalEquity
        )
    }
    
    private func calculateRentingCosts() -> RentingResults {
        let rent = Double(monthlyRent) ?? 0
        let increase = (Double(rentIncrease) ?? 3) / 100
        let insurance = Double(rentersInsurance) ?? 0
        let years = Double(yearsToAnalyze) ?? 5
        
        var totalCost = 0.0
        var currentRent = rent
        
        for year in 0..<Int(years) {
            let yearlyRent = currentRent * 12
            let yearlyInsurance = insurance * 12
            totalCost += yearlyRent + yearlyInsurance
            currentRent *= (1 + increase)
        }
        
        let averageMonthlyPayment = totalCost / (years * 12)
        
        return RentingResults(
            initialRent: rent,
            finalRent: rent * pow(1 + increase, years),
            monthlyInsurance: insurance,
            averageMonthlyPayment: averageMonthlyPayment,
            totalCost: totalCost
        )
    }
    
    private func calculatePrincipalPaid(loanAmount: Double, rate: Double, term: Double, years: Double) -> Double {
        var balance = loanAmount
        let monthlyPayment = rate > 0 ? 
            loanAmount * (rate * pow(1 + rate, term)) / (pow(1 + rate, term) - 1) : 
            loanAmount / term
        
        var principalPaid = 0.0
        let months = Int(years * 12)
        
        for _ in 0..<months {
            let interestPayment = balance * rate
            let principalPayment = monthlyPayment - interestPayment
            principalPaid += principalPayment
            balance -= principalPayment
            
            if balance <= 0 { break }
        }
        
        return principalPaid
    }
    
    private func calculateBreakEvenPoint() -> Double {
        // Simplified break-even calculation
        let buyingMonthly = buyingResults.totalMonthlyPayment
        let rentingMonthly = Double(monthlyRent) ?? 0
        let downPayment = Double(self.downPayment) ?? 0
        
        if buyingMonthly <= rentingMonthly {
            return 0 // Buying is immediately better
        }
        
        let monthlyDifference = buyingMonthly - rentingMonthly
        let monthsToBreakEven = downPayment / monthlyDifference
        
        return monthsToBreakEven / 12 // Convert to years
    }
    
    private func moveFocusToPrevious() {
        let allFields = RentVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .yearsToAnalyze) else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : allFields.count - 1
        focusedField = allFields[previousIndex]
    }
    
    private func moveFocusToNext() {
        let allFields = RentVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .yearsToAnalyze) else { return }
        let nextIndex = currentIndex < allFields.count - 1 ? currentIndex + 1 : 0
        focusedField = allFields[nextIndex]
    }
    
    private func hasPreviousField() -> Bool {
        let allFields = RentVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .yearsToAnalyze) else { return false }
        return currentIndex > 0
    }
    
    private func hasNextField() -> Bool {
        let allFields = RentVsBuyField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .yearsToAnalyze) else { return false }
        return currentIndex < allFields.count - 1
    }
    
    private func fillDemoDataAndCalculate() {
        homePrice = "400000"
        downPayment = "80000"
        mortgageRate = "7.0"
        mortgageTerm = "30"
        propertyTax = "500"
        homeInsurance = "150"
        pmi = "200"
        hoaFees = "0"
        maintenance = "300"
        monthlyRent = "2500"
        rentIncrease = "3.0"
        rentersInsurance = "25"
        yearsToAnalyze = "5"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        homePrice = ""
        downPayment = ""
        mortgageRate = ""
        mortgageTerm = ""
        propertyTax = ""
        homeInsurance = ""
        pmi = ""
        hoaFees = ""
        maintenance = ""
        monthlyRent = ""
        rentIncrease = ""
        rentersInsurance = ""
        yearsToAnalyze = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let netBuying = buyingResults.finalEquity - buyingResults.totalCost
        let netRenting = -rentingResults.totalCost
        let netDifference = netBuying - netRenting
        
        let shareText = """
        Rent vs Buy Home Analysis:
        
        🏠 Home Price: $\(homePrice)
        📅 Analysis Period: \(yearsToAnalyze) years
        
        💰 BUYING OPTION:
        Down Payment: $\(downPayment)
        Monthly Payment: $\(String(format: "%.0f", buyingResults.totalMonthlyPayment))
        Total Cost: $\(String(format: "%.0f", buyingResults.totalCost))
        Final Equity: $\(String(format: "%.0f", buyingResults.finalEquity))
        
        🔑 RENTING OPTION:
        Starting Rent: $\(monthlyRent)/mo
        Average Monthly: $\(String(format: "%.0f", rentingResults.averageMonthlyPayment))
        Total Cost: $\(String(format: "%.0f", rentingResults.totalCost))
        Final Equity: $0
        
        🎯 Net Worth Impact:
        \(netDifference > 0 ? "Buying is $\(String(format: "%.0f", netDifference)) better" : "Renting is $\(String(format: "%.0f", abs(netDifference))) better")
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

struct HomeBuyingResults {
    let monthlyMortgage: Double
    let monthlyPropertyTax: Double
    let monthlyInsurance: Double
    let monthlyPMI: Double
    let monthlyMaintenance: Double
    let totalMonthlyPayment: Double
    let downPaymentAmount: Double
    let totalCost: Double
    let finalEquity: Double
}

struct RentingResults {
    let initialRent: Double
    let finalRent: Double
    let monthlyInsurance: Double
    let averageMonthlyPayment: Double
    let totalCost: Double
}

struct HomeCostRow: View {
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

struct RentVsBuyHomeInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Rent vs Buy Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Compares total cost of renting vs buying
                            • Factors in mortgage, taxes, insurance, maintenance
                            • Calculates equity building and net worth impact
                            • Shows break-even point for your situation
                            """
                        )
                        
                        InfoSection(
                            title: "When to Buy",
                            content: """
                            • You plan to stay 5+ years
                            • You have stable income and emergency fund
                            • You can afford 20% down payment
                            • Local home prices are reasonable vs rent
                            """
                        )
                        
                        InfoSection(
                            title: "When to Rent",
                            content: """
                            • You may move in next 3-5 years
                            • You want flexibility and lower responsibility
                            • Home prices are very high vs rental costs
                            • You prefer investing down payment in stocks
                            """
                        )
                        
                        InfoSection(
                            title: "Key Factors",
                            content: """
                            • Length of time you'll stay is crucial
                            • Local market conditions vary greatly
                            • Consider opportunity cost of down payment
                            • Factor in closing costs and moving expenses
                            • Property taxes and HOA fees add up
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Rent vs Buy Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}