import SwiftUI
import Charts
import Combine

struct EVChargingCostView: View {
    @State private var batteryCapacity = ""
    @State private var dailyMiles = ""
    @State private var vehicleEfficiency = ""
    @State private var electricityRate = ""
    @State private var chargingEfficiency = "90"
    @State private var chargeLevel = ChargeLevel.home
    @State private var currentCharge = "20"
    @State private var targetCharge = "80"
    
    @State private var showResults = false
    @State private var selectedEV: EVModel? = nil
    @State private var showEVPicker = false
    @State private var isDemoActive = false
    @State private var showInfo = false
    @FocusState private var focusedField: EVField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum EVField: CaseIterable {
        case batteryCapacity, vehicleEfficiency, dailyMiles, electricityRate, chargingEfficiency
    }
    
    enum ChargeLevel: String, CaseIterable {
        case home = "Home (Level 2)"
        case publicCharging = "Public (Level 2)"
        case fastCharging = "DC Fast Charging"
        
        var defaultRate: Double {
            switch self {
            case .home: return 0.13
            case .publicCharging: return 0.20
            case .fastCharging: return 0.35
            }
        }
    }
    
    struct EVModel: Identifiable {
        let id = UUID()
        let name: String
        let batteryCapacity: Double // kWh
        let efficiency: Double // miles/kWh
    }
    
    let popularEVs = [
        EVModel(name: "Tesla Model 3 Long Range", batteryCapacity: 82, efficiency: 4.0),
        EVModel(name: "Tesla Model Y", batteryCapacity: 75, efficiency: 3.8),
        EVModel(name: "Chevrolet Bolt EV", batteryCapacity: 65, efficiency: 3.9),
        EVModel(name: "Ford Mustang Mach-E", batteryCapacity: 88, efficiency: 3.5),
        EVModel(name: "Nissan Leaf Plus", batteryCapacity: 62, efficiency: 3.8),
        EVModel(name: "Volkswagen ID.4", batteryCapacity: 82, efficiency: 3.4),
        EVModel(name: "Hyundai Ioniq 5", batteryCapacity: 77.4, efficiency: 3.7),
        EVModel(name: "Kia EV6", batteryCapacity: 77.4, efficiency: 3.6),
        EVModel(name: "Rivian R1T", batteryCapacity: 135, efficiency: 2.1),
        EVModel(name: "Ford F-150 Lightning", batteryCapacity: 131, efficiency: 2.4)
    ]
    
    // Calculations
    var kWhNeededForCharge: Double {
        guard let capacity = Double(batteryCapacity),
              let current = Double(currentCharge),
              let target = Double(targetCharge),
              let efficiency = Double(chargingEfficiency),
              capacity > 0, efficiency > 0 else { return 0 }
        
        let percentToCharge = (target - current) / 100
        return (capacity * percentToCharge) / (efficiency / 100)
    }
    
    var costPerCharge: Double {
        guard let rate = Double(electricityRate) else { return 0 }
        return kWhNeededForCharge * rate
    }
    
    var dailyKWhNeeded: Double {
        guard let miles = Double(dailyMiles),
              let efficiency = Double(vehicleEfficiency),
              let chargingEff = Double(chargingEfficiency),
              efficiency > 0, chargingEff > 0 else { return 0 }
        
        return (miles / efficiency) / (chargingEff / 100)
    }
    
    var dailyCost: Double {
        guard let rate = Double(electricityRate) else { return 0 }
        return dailyKWhNeeded * rate
    }
    
    var monthlyKWh: Double {
        dailyKWhNeeded * 30
    }
    
    var monthlyCost: Double {
        dailyCost * 30
    }
    
    var yearlyKWh: Double {
        dailyKWhNeeded * 365
    }
    
    var yearlyCost: Double {
        dailyCost * 365
    }
    
    var costPerMile: Double {
        guard let miles = Double(dailyMiles), miles > 0 else { return 0 }
        return dailyCost / miles
    }
    
    var fullChargeRange: Double {
        guard let capacity = Double(batteryCapacity),
              let efficiency = Double(vehicleEfficiency) else { return 0 }
        return capacity * efficiency
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(
                title: "EV Charging Cost",
                description: "Calculate electric vehicle charging expenses"
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
                // Vehicle Information
                GroupedInputFields(
                    title: "Vehicle Information",
                    icon: "car.fill",
                    color: .blue
                ) {
                    Button(action: { showEVPicker = true }) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                            Text(selectedEV?.name ?? "Select Popular EV Model")
                                .foregroundColor(selectedEV != nil ? .primary : .secondary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                
                    ModernInputField(
                        title: "Battery Capacity",
                        value: $batteryCapacity,
                        placeholder: "75",
                        suffix: "kWh",
                        icon: "battery.100",
                        color: .green,
                        keyboardType: .decimalPad,
                        helpText: "Total battery capacity of your EV",
                        onNext: { focusNextField(.batteryCapacity) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .batteryCapacity)
                    .id(EVField.batteryCapacity)
                    
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Vehicle Efficiency",
                            value: $vehicleEfficiency,
                            placeholder: "3.5",
                            suffix: "mi/kWh",
                            color: .purple,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.vehicleEfficiency) },
                            onNext: { focusNextField(.vehicleEfficiency) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .vehicleEfficiency)
                        .id(EVField.vehicleEfficiency)
                        
                        CompactInputField(
                            title: "Daily Miles",
                            value: $dailyMiles,
                            placeholder: "40",
                            suffix: "miles",
                            color: .orange,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.dailyMiles) },
                            onNext: { focusNextField(.dailyMiles) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .dailyMiles)
                        .id(EVField.dailyMiles)
                    }
                }
                
                // Charging Settings
                GroupedInputFields(
                    title: "Charging Settings",
                    icon: "bolt.fill",
                    color: .orange
                ) {
                    SegmentedPicker(
                        title: "Charging Location",
                        selection: $chargeLevel,
                        options: ChargeLevel.allCases.map { ($0, $0.rawValue) }
                    )
                    .onChange(of: chargeLevel) { newValue in
                        if electricityRate.isEmpty {
                            electricityRate = String(format: "%.2f", newValue.defaultRate)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Electricity Rate",
                            value: $electricityRate,
                            placeholder: "0.13",
                            prefix: "$",
                            suffix: "/kWh",
                            color: .red,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.electricityRate) },
                            onNext: { focusNextField(.electricityRate) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .electricityRate)
                        .id(EVField.electricityRate)
                        
                        CompactInputField(
                            title: "Charging Efficiency",
                            value: $chargingEfficiency,
                            placeholder: "90",
                            suffix: "%",
                            color: .green,
                            keyboardType: .decimalPad,
                            onPrevious: { focusPreviousField(.chargingEfficiency) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .chargingEfficiency)
                        .id(EVField.chargingEfficiency)
                    }
                    
                    // Charge Level Sliders
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "battery.75")
                                .foregroundColor(.blue)
                            Text("Single Charge Calculator")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Current: \(currentCharge)%")
                            Spacer()
                            Text("Target: \(targetCharge)%")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Slider(value: Binding(
                                    get: { Double(currentCharge) ?? 20 },
                                    set: { currentCharge = String(format: "%.0f", $0) }
                                ), in: 0...100, step: 5)
                                .tint(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Target")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Slider(value: Binding(
                                    get: { Double(targetCharge) ?? 80 },
                                    set: { targetCharge = String(format: "%.0f", $0) }
                                ), in: 0...100, step: 5)
                                .tint(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Charging Costs") {
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
                if showResults {
                    VStack(spacing: 20) {
                        Divider()
                            .id("results")
                        
                        Text("Charging Cost Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Single Charge Cost
                        CalculatorResultCard(
                            title: "Cost per Charge",
                            value: NumberFormatter.formatCurrency(costPerCharge),
                            subtitle: "\(NumberFormatter.formatDecimal(kWhNeededForCharge)) kWh needed (\(currentCharge)% → \(targetCharge)%)",
                            color: .blue
                        )
                        
                        // Daily/Monthly/Yearly Costs
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Daily Cost",
                                    value: NumberFormatter.formatCurrency(dailyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(dailyKWhNeeded)) kWh",
                                    color: .green
                                )
                                
                                CalculatorResultCard(
                                    title: "Cost per Mile",
                                    value: NumberFormatter.formatCurrency(costPerMile),
                                    color: .orange
                                )
                            }
                            
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Monthly Cost",
                                    value: NumberFormatter.formatCurrency(monthlyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(monthlyKWh)) kWh",
                                    color: .purple
                                )
                                
                                CalculatorResultCard(
                                    title: "Yearly Cost",
                                    value: NumberFormatter.formatCurrency(yearlyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(yearlyKWh)) kWh",
                                    color: .red
                                )
                            }
                        }
                        
                        // Charging Time Estimates
                        ChargingTimeEstimates(
                            kWhNeeded: kWhNeededForCharge,
                            chargeLevel: chargeLevel
                        )
                        
                        // Range Information
                        if !batteryCapacity.isEmpty && !vehicleEfficiency.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "speedometer")
                                        .foregroundColor(.blue)
                                    Text("Range Information")
                                        .font(.headline)
                                }
                                
                                InfoRow(
                                    label: "Full Charge Range",
                                    value: "\(NumberFormatter.formatDecimal(fullChargeRange)) miles"
                                )
                                
                                InfoRow(
                                    label: "Days per Full Charge",
                                    value: NumberFormatter.formatDecimal(fullChargeRange / (Double(dailyMiles) ?? 1))
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Cost Comparison
                        CostComparisonView(yearlyEVCost: yearlyCost)
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
            EVChargingInfoSheet()
        }
        .sheet(isPresented: $showEVPicker) {
            EVModelPicker(
                models: popularEVs,
                selectedModel: $selectedEV,
                onSelect: { model in
                    batteryCapacity = String(format: "%.0f", model.batteryCapacity)
                    vehicleEfficiency = String(format: "%.1f", model.efficiency)
                    showEVPicker = false
                }
            )
        }
    }
    
    private func focusNextField(_ currentField: EVField) {
        let allFields = EVField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: EVField) {
        let allFields = EVField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        batteryCapacity = "75"
        dailyMiles = "40"
        vehicleEfficiency = "3.5"
        electricityRate = "0.13"
        chargingEfficiency = "90"
        chargeLevel = .home
        currentCharge = "20"
        targetCharge = "80"
        selectedEV = nil
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        batteryCapacity = ""
        dailyMiles = ""
        vehicleEfficiency = ""
        electricityRate = ""
        chargingEfficiency = "90"
        chargeLevel = .home
        currentCharge = "20"
        targetCharge = "80"
        selectedEV = nil
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        EV Charging Cost Analysis:
        Vehicle: \(selectedEV?.name ?? "Custom EV")
        Battery: \(batteryCapacity) kWh
        Daily Miles: \(dailyMiles) miles
        Electricity Rate: $\(electricityRate)/kWh
        Daily Cost: \(NumberFormatter.formatCurrency(dailyCost))
        Monthly Cost: \(NumberFormatter.formatCurrency(monthlyCost))
        Yearly Cost: \(NumberFormatter.formatCurrency(yearlyCost))
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

struct ChargingTimeEstimates: View {
    let kWhNeeded: Double
    let chargeLevel: EVChargingCostView.ChargeLevel
    
    var level2Time: Double {
        kWhNeeded / 7.2 // Typical Level 2 charger at 7.2kW
    }
    
    var dcFastTime: Double {
        kWhNeeded / 150 // Typical DC fast charger at 150kW
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Charging Time Estimates")
                    .font(.headline)
            }
            
            InfoRow(
                label: "Level 2 (7.2kW)",
                value: formatTime(level2Time)
            )
            
            InfoRow(
                label: "DC Fast (150kW)",
                value: formatTime(dcFastTime)
            )
            
            Text("Actual charging times may vary based on charger output and vehicle limitations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatTime(_ hours: Double) -> String {
        if hours < 1 {
            return "\(Int(hours * 60)) minutes"
        } else {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            return "\(h)h \(m)m"
        }
    }
}

struct CostComparisonView: View {
    let yearlyEVCost: Double
    
    var yearlyGasCost: Double {
        // Assume 12,000 miles/year, 25 mpg, $3.50/gallon
        (12000 / 25) * 3.50
    }
    
    var savings: Double {
        yearlyGasCost - yearlyEVCost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.green)
                Text("Annual Cost Comparison")
                    .font(.headline)
            }
            
            Chart {
                BarMark(
                    x: .value("Type", "Gas Vehicle"),
                    y: .value("Cost", yearlyGasCost)
                )
                .foregroundStyle(.red)
                
                BarMark(
                    x: .value("Type", "Electric Vehicle"),
                    y: .value("Cost", yearlyEVCost)
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(NumberFormatter.formatCurrency(amount))
                        }
                    }
                }
            }
            
            Text("Annual Savings: \(NumberFormatter.formatCurrency(savings))")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Based on average gas vehicle (25 mpg) at $3.50/gallon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EVModelPicker: View {
    let models: [EVChargingCostView.EVModel]
    @Binding var selectedModel: EVChargingCostView.EVModel?
    let onSelect: (EVChargingCostView.EVModel) -> Void
    
    var body: some View {
        NavigationView {
            List(models) { model in
                Button(action: { onSelect(model) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(model.name)
                                .font(.headline)
                            Text("\(Int(model.batteryCapacity)) kWh • \(String(format: "%.1f", model.efficiency)) mi/kWh")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedModel?.id == model.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select EV Model")
            .navigationBarItems(trailing: Button("Done") {
                onSelect(selectedModel ?? models[0])
            })
        }
    }
}

struct EVChargingInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About EV Charging Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates your electric vehicle charging costs including daily, monthly, and yearly expenses based on your driving habits and local electricity rates."
                        )
                        
                        InfoSection(
                            title: "Key Factors",
                            content: """
                            • Battery Capacity: Total kWh your EV can store
                            • Vehicle Efficiency: Miles per kWh your EV achieves
                            • Electricity Rate: Cost per kWh from your utility
                            • Charging Efficiency: Energy loss during charging (typically 85-95%)
                            """
                        )
                        
                        InfoSection(
                            title: "Charging Types",
                            content: """
                            • Home (Level 2): Typically $0.10-0.20/kWh
                            • Public (Level 2): Usually $0.15-0.30/kWh
                            • DC Fast Charging: Often $0.25-0.50/kWh
                            """
                        )
                        
                        InfoSection(
                            title: "Money-Saving Tips",
                            content: """
                            • Charge at home during off-peak hours
                            • Take advantage of time-of-use electricity rates
                            • Use workplace charging if available
                            • Plan routes to minimize expensive fast charging
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("EV Charging Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        EVChargingCostView()
    }
}