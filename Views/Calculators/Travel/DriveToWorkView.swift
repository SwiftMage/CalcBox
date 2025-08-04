import SwiftUI

struct DriveToWorkView: View {
    @State private var vehicleType = VehicleType.gas
    @State private var dailyMiles = ""
    @State private var workDaysPerWeek = ""
    
    // Gas vehicle inputs
    @State private var mpg = ""
    @State private var gasPrice = ""
    
    // Electric vehicle inputs
    @State private var milesPerKWh = ""
    @State private var electricityRate = ""
    @State private var chargingEfficiency = "90"
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: FocusableField?
    
    enum FocusableField: Hashable {
        case dailyMiles, workDaysPerWeek, mpg, gasPrice, milesPerKWh, electricityRate, chargingEfficiency
    }
    
    private let category = CalcBoxColors.CategoryColors.travel
    
    enum VehicleType: String, CaseIterable {
        case gas = "Gas Vehicle"
        case electric = "Electric Vehicle"
        
        var icon: String {
            switch self {
            case .gas: return "fuelpump.fill"
            case .electric: return "bolt.car.fill"
            }
        }
    }
    
    // Gas calculations
    var dailyGallons: Double {
        guard let miles = Double(dailyMiles),
              let mpgValue = Double(mpg),
              mpgValue > 0 else { return 0 }
        return miles / mpgValue
    }
    
    var dailyGasCost: Double {
        guard let price = Double(gasPrice) else { return 0 }
        return dailyGallons * price
    }
    
    // Electric calculations
    var dailyKWh: Double {
        guard let miles = Double(dailyMiles),
              let efficiency = Double(milesPerKWh),
              let charging = Double(chargingEfficiency),
              efficiency > 0, charging > 0 else { return 0 }
        return (miles / efficiency) / (charging / 100)
    }
    
    var dailyElectricCost: Double {
        guard let rate = Double(electricityRate) else { return 0 }
        return dailyKWh * rate
    }
    
    // Common calculations
    var weeklyMiles: Double {
        guard let miles = Double(dailyMiles),
              let days = Double(workDaysPerWeek) else { return 0 }
        return miles * days
    }
    
    var monthlyMiles: Double {
        weeklyMiles * 4.33 // Average weeks per month
    }
    
    var yearlyMiles: Double {
        weeklyMiles * 52
    }
    
    var weeklyCost: Double {
        guard let days = Double(workDaysPerWeek) else { return 0 }
        let dailyCost = vehicleType == .gas ? dailyGasCost : dailyElectricCost
        return dailyCost * days
    }
    
    var monthlyCost: Double {
        weeklyCost * 4.33
    }
    
    var yearlyCost: Double {
        weeklyCost * 52
    }
    
    // CO2 calculations (lbs per year)
    var gasCO2Emissions: Double {
        // Average: 19.6 lbs CO2 per gallon of gasoline
        dailyGallons * (Double(workDaysPerWeek) ?? 0) * 52 * 19.6
    }
    
    var electricCO2Emissions: Double {
        // Average US grid: 0.85 lbs CO2 per kWh
        dailyKWh * (Double(workDaysPerWeek) ?? 0) * 52 * 0.85
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .font(.title2)
                                .foregroundColor(category.primary)
                                .frame(width: 32, height: 32)
                                .background(category.light)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Drive to Work")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(CalcBoxColors.Text.primary)
                                
                                Text("Compare commuting costs for gas and electric vehicles")
                                    .font(.subheadline)
                                    .foregroundColor(CalcBoxColors.Text.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions
                    QuickActionButtonRow(
                        onExample: fillExampleData,
                        onClear: clearAllData,
                        onInfo: { showInfo = true },
                        onShare: shareResults,
                        showShare: showResults
                    )
                    .padding(.horizontal, 20)
                    
                    // Vehicle Type Selection
                    SegmentedInputField(
                        title: "Vehicle Type",
                        selection: $vehicleType,
                        options: VehicleType.allCases.map { ($0, $0.rawValue) },
                        icon: "car.2.fill",
                        color: category.primary
                    )
                    .padding(.horizontal, 20)
                    
                    // Common Inputs
                    GroupedInputFields(
                        title: "Commute Details",
                        icon: "location.fill",
                        color: category.primary
                    ) {
                        ModernInputField(
                            title: "Daily Commute Distance",
                            value: $dailyMiles,
                            placeholder: "30",
                            suffix: "miles",
                            icon: "location.circle.fill",
                            color: category.primary,
                            onPrevious: { focusPrevious() },
                            onNext: { focusNext() },
                            onDone: { calculate() }
                        )
                        .focused($focusedField, equals: .dailyMiles)
                        
                        ModernInputField(
                            title: "Work Days Per Week",
                            value: $workDaysPerWeek,
                            placeholder: "5",
                            suffix: "days",
                            icon: "calendar.badge.clock",
                            color: category.primary,
                            onPrevious: { focusPrevious() },
                            onNext: { focusNext() },
                            onDone: { calculate() }
                        )
                        .focused($focusedField, equals: .workDaysPerWeek)
                    }
                    .padding(.horizontal, 20)
                    
                    // Vehicle-specific inputs
                    if vehicleType == .gas {
                        GroupedInputFields(
                            title: "Gas Vehicle Details",
                            icon: "fuelpump.fill",
                            color: category.primary
                        ) {
                            ModernInputField(
                                title: "Miles Per Gallon (MPG)",
                                value: $mpg,
                                placeholder: "25",
                                suffix: "mpg",
                                icon: "speedometer",
                                color: category.primary,
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .mpg)
                            
                            ModernInputField(
                                title: "Gas Price",
                                value: $gasPrice,
                                placeholder: "3.50",
                                prefix: "$",
                                suffix: "per gallon",
                                icon: "dollarsign.circle.fill",
                                color: category.primary,
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .gasPrice)
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vehicleType)
                    } else {
                        GroupedInputFields(
                            title: "Electric Vehicle Details",
                            icon: "bolt.car.fill",
                            color: category.primary
                        ) {
                            ModernInputField(
                                title: "Vehicle Efficiency",
                                value: $milesPerKWh,
                                placeholder: "3.5",
                                suffix: "miles/kWh",
                                icon: "bolt.fill",
                                color: category.primary,
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .milesPerKWh)
                            
                            ModernInputField(
                                title: "Electricity Rate",
                                value: $electricityRate,
                                placeholder: "0.13",
                                prefix: "$",
                                suffix: "per kWh",
                                icon: "bolt.circle.fill",
                                color: category.primary,
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .electricityRate)
                            
                            ModernInputField(
                                title: "Charging Efficiency",
                                value: $chargingEfficiency,
                                placeholder: "90",
                                suffix: "%",
                                icon: "battery.100",
                                color: category.primary,
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .chargingEfficiency)
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vehicleType)
                    }
                    
                    // Calculate Button
                    CalculatorButton(
                        title: "Calculate Commuting Costs",
                        category: category,
                        isDisabled: !canCalculate
                    ) {
                        calculate()
                    }
                    .padding(.horizontal, 20)
                
                    // Results
                    if showResults {
                        VStack(spacing: 24) {
                            // Cost Breakdown Cards
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Daily Cost",
                                        value: NumberFormatter.formatCurrency(vehicleType == .gas ? dailyGasCost : dailyElectricCost),
                                        subtitle: vehicleType == .gas ? 
                                            "\(NumberFormatter.formatDecimal(dailyGallons, precision: 1)) gallons" : 
                                            "\(NumberFormatter.formatDecimal(dailyKWh, precision: 1)) kWh",
                                        color: category.primary,
                                        category: category
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Weekly Cost",
                                        value: NumberFormatter.formatCurrency(weeklyCost),
                                        subtitle: "\(NumberFormatter.formatDecimal(weeklyMiles)) miles",
                                        color: category.secondary,
                                        category: category
                                    )
                                }
                                
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Monthly Cost",
                                        value: NumberFormatter.formatCurrency(monthlyCost),
                                        subtitle: "\(NumberFormatter.formatDecimal(monthlyMiles)) miles",
                                        color: category.accent,
                                        category: category
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Yearly Cost",
                                        value: NumberFormatter.formatCurrency(yearlyCost),
                                        subtitle: "\(NumberFormatter.formatDecimal(yearlyMiles)) miles",
                                        color: category.primary,
                                        category: category
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .id("results")
                            
                            // Cost Analysis Section
                            InfoSection(
                                title: "Cost Analysis",
                                content: buildCostAnalysisText(),
                                accentColor: category.primary
                            )
                            .padding(.horizontal, 20)
                            
                            // Environmental Impact Section
                            InfoSection(
                                title: "Environmental Impact",
                                content: buildEnvironmentalText(),
                                accentColor: .green
                            )
                            .padding(.horizontal, 20)
                            
                            // Comparison Tip
                            if vehicleType == .gas && canCalculate {
                                ComparisonTip(
                                    gasCost: yearlyCost,
                                    estimatedEVCost: calculateEstimatedEVCost(),
                                    category: category
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
            }
            .background(CalcBoxColors.Gradients.categoryBackground(category).ignoresSafeArea())
            .navigationTitle("Drive to Work")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showInfo) {
                DriveToWorkInfoSheet()
            }
            .onChange(of: focusedField) { newValue in
                if let field = newValue {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
            .onChange(of: showResults) { newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                        proxy.scrollTo("results", anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canCalculate: Bool {
        guard !dailyMiles.isEmpty && !workDaysPerWeek.isEmpty else { return false }
        
        if vehicleType == .gas {
            return !mpg.isEmpty && !gasPrice.isEmpty
        } else {
            return !milesPerKWh.isEmpty && !electricityRate.isEmpty
        }
    }
    
    // MARK: - Actions
    
    private func calculate() {
        focusedField = nil
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showResults = true
        }
    }
    
    private func fillExampleData() {
        dailyMiles = "25"
        workDaysPerWeek = "5"
        vehicleType = .gas
        mpg = "28"
        gasPrice = "3.50"
        milesPerKWh = "3.5"
        electricityRate = "0.13"
        chargingEfficiency = "90"
        
        // Auto-calculate after filling demo data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            calculate()
        }
    }
    
    private func clearAllData() {
        dailyMiles = ""
        workDaysPerWeek = ""
        vehicleType = .gas
        mpg = ""
        gasPrice = ""
        milesPerKWh = ""
        electricityRate = ""
        chargingEfficiency = "90"
        focusedField = nil
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showResults = false
        }
    }
    
    private func shareResults() {
        let costType = vehicleType == .gas ? "gas" : "electric"
        let dailyCost = vehicleType == .gas ? dailyGasCost : dailyElectricCost
        let yearlyEmissions = vehicleType == .gas ? gasCO2Emissions : electricCO2Emissions
        
        let shareText = """
        🚗 My Commute Analysis (\(costType.capitalized) Vehicle)
        
        Daily commute: \(dailyMiles) miles
        Daily cost: \(NumberFormatter.formatCurrency(dailyCost))
        Weekly cost: \(NumberFormatter.formatCurrency(weeklyCost))
        Monthly cost: \(NumberFormatter.formatCurrency(monthlyCost))
        Yearly cost: \(NumberFormatter.formatCurrency(yearlyCost))
        
        Annual CO₂ emissions: \(NumberFormatter.formatDecimal(yearlyEmissions)) lbs
        
        Calculated with CalcBox
        """
        
        let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    // MARK: - Focus Management
    
    private func focusPrevious() {
        switch focusedField {
        case .workDaysPerWeek:
            focusedField = .dailyMiles
        case .mpg:
            focusedField = .workDaysPerWeek
        case .gasPrice:
            focusedField = .mpg
        case .milesPerKWh:
            focusedField = .workDaysPerWeek
        case .electricityRate:
            focusedField = .milesPerKWh
        case .chargingEfficiency:
            focusedField = .electricityRate
        default:
            break
        }
    }
    
    private func focusNext() {
        switch focusedField {
        case .dailyMiles:
            focusedField = .workDaysPerWeek
        case .workDaysPerWeek:
            if vehicleType == .gas {
                focusedField = .mpg
            } else {
                focusedField = .milesPerKWh
            }
        case .mpg:
            focusedField = .gasPrice
        case .gasPrice:
            focusedField = nil
        case .milesPerKWh:
            focusedField = .electricityRate
        case .electricityRate:
            focusedField = .chargingEfficiency
        case .chargingEfficiency:
            focusedField = nil
        default:
            break
        }
    }
    
    // MARK: - Text Builders
    
    private func buildCostAnalysisText() -> String {
        let costPerMile = (vehicleType == .gas ? dailyGasCost : dailyElectricCost) / (Double(dailyMiles) ?? 1)
        var text = "Cost per mile: \(NumberFormatter.formatCurrency(costPerMile))\n\n"
        
        if vehicleType == .gas {
            let annualGallons = dailyGallons * (Double(workDaysPerWeek) ?? 0) * 52
            text += "Annual fuel consumption: \(NumberFormatter.formatDecimal(annualGallons)) gallons"
        } else {
            let annualKWh = dailyKWh * (Double(workDaysPerWeek) ?? 0) * 52
            text += "Annual energy consumption: \(NumberFormatter.formatDecimal(annualKWh)) kWh"
        }
        
        return text
    }
    
    private func buildEnvironmentalText() -> String {
        let emissions = vehicleType == .gas ? gasCO2Emissions : electricCO2Emissions
        var text = "Annual CO₂ emissions: \(NumberFormatter.formatDecimal(emissions)) lbs\n\n"
        
        if vehicleType == .electric {
            text += "Electric vehicle emissions are based on US average grid mix (0.85 lbs CO₂ per kWh). Actual emissions may vary based on your local electricity source."
        } else {
            text += "Gas vehicle emissions are calculated at 19.6 lbs CO₂ per gallon of gasoline burned."
        }
        
        return text
    }
    
    private func calculateEstimatedEVCost() -> Double {
        // Estimate EV cost using typical values
        let typicalMilesPerKWh = 3.5
        let typicalElectricityRate = 0.13
        let typicalChargingEfficiency = 0.9
        
        guard let miles = Double(dailyMiles),
              let days = Double(workDaysPerWeek) else { return 0 }
        
        let dailyKWh = (miles / typicalMilesPerKWh) / typicalChargingEfficiency
        let dailyCost = dailyKWh * typicalElectricityRate
        return dailyCost * days * 52
    }
}

struct DriveToWorkInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let category = CalcBoxColors.CategoryColors.travel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .font(.title)
                                .foregroundColor(category.primary)
                                .frame(width: 40, height: 40)
                                .background(category.light)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Drive to Work Calculator")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(CalcBoxColors.Text.primary)
                                
                                Text("Compare commuting costs and environmental impact")
                                    .font(.subheadline)
                                    .foregroundColor(CalcBoxColors.Text.secondary)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator helps you understand the true cost of your daily commute by comparing gas vehicles vs electric vehicles across different time periods (daily, weekly, monthly, and yearly).",
                            accentColor: category.primary
                        )
                        
                        InfoSection(
                            title: "Gas Vehicle Calculations",
                            content: """
                            🚗 Fuel Consumption: Daily miles ÷ MPG = gallons per day
                            💰 Daily Cost: Gallons × Gas price per gallon
                            🌍 CO₂ Emissions: ~19.6 lbs per gallon of gasoline
                            📊 Extended Periods: Daily amounts × days in period
                            """,
                            accentColor: .orange
                        )
                        
                        InfoSection(
                            title: "Electric Vehicle Calculations",
                            content: """
                            🔋 Energy Usage: (Miles ÷ Vehicle efficiency) ÷ Charging efficiency
                            💰 Daily Cost: kWh consumed × Electricity rate
                            🌍 CO₂ Emissions: ~0.85 lbs per kWh (US grid average)
                            ⚡ Charging Efficiency: Accounts for energy loss during charging
                            """,
                            accentColor: .blue
                        )
                        
                        InfoSection(
                            title: "Tips for Accuracy",
                            content: """
                            📍 Use your actual round-trip commute distance
                            🚙 Check your vehicle's real-world efficiency (not EPA estimates)
                            💵 Use current local gas prices and electricity rates
                            🌡️ Consider seasonal variations in vehicle efficiency
                            🔌 For EVs, use your home electricity rate or charging station costs
                            """,
                            accentColor: .green
                        )
                        
                        InfoSection(
                            title: "Understanding the Results",
                            content: """
                            The calculator provides cost breakdowns for different time periods and includes environmental impact analysis. The EV comparison feature estimates potential savings when switching from gas to electric vehicles.
                            
                            Remember that total cost of ownership includes factors beyond fuel costs, such as maintenance, insurance, and vehicle depreciation.
                            """,
                            accentColor: category.accent
                        )
                    }
                }
                .padding(20)
            }
            .background(CalcBoxColors.Gradients.categoryBackground(category).ignoresSafeArea())
            .navigationTitle("Calculator Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(category.primary)
                }
            }
        }
    }
}

struct ComparisonTip: View {
    let gasCost: Double
    let estimatedEVCost: Double
    let category: CalcBoxColors.CategoryColors
    
    var savings: Double {
        gasCost - estimatedEVCost
    }
    
    var isGoodSavings: Bool {
        savings > 500
    }
    
    var body: some View {
        InfoSection(
            title: "💡 EV Comparison",
            content: buildComparisonText(),
            accentColor: isGoodSavings ? .green : .orange
        )
    }
    
    private func buildComparisonText() -> String {
        if savings > 0 {
            return """
            Switching to an electric vehicle could save you approximately \(NumberFormatter.formatCurrency(savings)) per year on fuel costs.
            
            This estimate is based on average electricity rates (\(NumberFormatter.formatCurrency(0.13))/kWh) and typical EV efficiency (3.5 miles/kWh).
            
            💰 Potential annual savings: \(NumberFormatter.formatCurrency(savings))
            📊 Gas vehicle annual cost: \(NumberFormatter.formatCurrency(gasCost))
            🔋 Estimated EV annual cost: \(NumberFormatter.formatCurrency(estimatedEVCost))
            """
        } else {
            return """
            Based on current electricity rates and your driving patterns, an electric vehicle might cost approximately \(NumberFormatter.formatCurrency(abs(savings))) more per year than your gas vehicle.
            
            However, consider factors like:
            • Lower maintenance costs for EVs
            • Potential tax incentives
            • Environmental benefits
            • Future gas price volatility
            """
        }
    }
}

#Preview {
    NavigationStack {
        DriveToWorkView()
    }
}