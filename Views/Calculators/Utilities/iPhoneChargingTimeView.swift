import SwiftUI

struct iPhoneChargingTimeView: View {
    @State private var phoneModel = iPhoneModel.iPhone15Pro
    @State private var chargerType = ChargerType.lightning5W
    @State private var startPercentage = "20"
    @State private var endPercentage = "80"
    @State private var showResults = false
    @State private var isDemoActive = false
    @State private var showInfo = false
    
    enum iPhoneModel: String, CaseIterable {
        case iPhone15ProMax = "iPhone 15 Pro Max"
        case iPhone15Pro = "iPhone 15 Pro"
        case iPhone15Plus = "iPhone 15 Plus"
        case iPhone15 = "iPhone 15"
        case iPhone14ProMax = "iPhone 14 Pro Max"
        case iPhone14Pro = "iPhone 14 Pro"
        case iPhone14Plus = "iPhone 14 Plus"
        case iPhone14 = "iPhone 14"
        case iPhone13ProMax = "iPhone 13 Pro Max"
        case iPhone13Pro = "iPhone 13 Pro"
        case iPhone13Mini = "iPhone 13 Mini"
        case iPhone13 = "iPhone 13"
        case iPhone12ProMax = "iPhone 12 Pro Max"
        case iPhone12Pro = "iPhone 12 Pro"
        case iPhone12Mini = "iPhone 12 Mini"
        case iPhone12 = "iPhone 12"
        case iPhoneSE3 = "iPhone SE (3rd gen)"
        
        var batteryCapacity: Double {
            switch self {
            case .iPhone15ProMax: return 4441
            case .iPhone15Pro: return 3274
            case .iPhone15Plus: return 4383
            case .iPhone15: return 3349
            case .iPhone14ProMax: return 4323
            case .iPhone14Pro: return 3200
            case .iPhone14Plus: return 4325
            case .iPhone14: return 3279
            case .iPhone13ProMax: return 4352
            case .iPhone13Pro: return 3095
            case .iPhone13Mini: return 2406
            case .iPhone13: return 3240
            case .iPhone12ProMax: return 3687
            case .iPhone12Pro: return 2815
            case .iPhone12Mini: return 2227
            case .iPhone12: return 2815
            case .iPhoneSE3: return 2018
            }
        }
        
        var maxChargingWatts: Double {
            switch self {
            case .iPhone15ProMax, .iPhone15Pro, .iPhone15Plus, .iPhone15: return 27
            case .iPhone14ProMax, .iPhone14Pro, .iPhone14Plus, .iPhone14: return 27
            case .iPhone13ProMax, .iPhone13Pro, .iPhone13Mini, .iPhone13: return 23
            case .iPhone12ProMax, .iPhone12Pro, .iPhone12Mini, .iPhone12: return 20
            case .iPhoneSE3: return 18
            }
        }
        
        var connector: String {
            switch self {
            case .iPhone15ProMax, .iPhone15Pro, .iPhone15Plus, .iPhone15: return "USB-C"
            default: return "Lightning"
            }
        }
    }
    
    enum ChargerType: String, CaseIterable {
        case lightning5W = "5W USB-A (In-box Legacy)"
        case lightning12W = "12W USB-A iPad Charger"
        case lightning18W = "18W USB-C Power Adapter"
        case lightning20W = "20W USB-C Power Adapter"
        case lightning30W = "30W USB-C Power Adapter"
        case lightning67W = "67W USB-C Power Adapter"
        case lightning96W = "96W USB-C Power Adapter"
        case magsafe15W = "15W MagSafe Charger"
        case magsafe25W = "25W MagSafe Charger (iPhone 15)"
        case qi75W = "7.5W Qi Wireless"
        case qi15W = "15W Qi2 Wireless"
        
        var maxWatts: Double {
            switch self {
            case .lightning5W: return 5
            case .lightning12W: return 12
            case .lightning18W: return 18
            case .lightning20W: return 20
            case .lightning30W: return 30
            case .lightning67W: return 67
            case .lightning96W: return 96
            case .magsafe15W: return 15
            case .magsafe25W: return 25
            case .qi75W: return 7.5
            case .qi15W: return 15
            }
        }
        
        var isWireless: Bool {
            switch self {
            case .magsafe15W, .magsafe25W, .qi75W, .qi15W: return true
            default: return false
            }
        }
        
        var efficiency: Double {
            switch self {
            case .magsafe15W, .magsafe25W: return 0.85 // MagSafe efficiency
            case .qi75W, .qi15W: return 0.75 // Qi wireless efficiency
            default: return 0.95 // Wired charging efficiency
            }
        }
    }
    
    var compatibleChargers: [ChargerType] {
        switch phoneModel.connector {
        case "USB-C":
            return ChargerType.allCases.filter { charger in
                !charger.rawValue.contains("Lightning") || charger.isWireless
            }
        case "Lightning":
            return ChargerType.allCases.filter { charger in
                !charger.rawValue.contains("25W MagSafe") // iPhone 15 only feature
            }
        default:
            return ChargerType.allCases
        }
    }
    
    var effectiveChargingWatts: Double {
        let chargerWatts = chargerType.maxWatts * chargerType.efficiency
        let phoneMaxWatts = phoneModel.maxChargingWatts
        return min(chargerWatts, phoneMaxWatts)
    }
    
    // Apple's charging curve - fast charging up to ~50%, then tapers off significantly
    func chargingSpeed(at percentage: Double) -> Double {
        let baseSpeed = effectiveChargingWatts
        
        switch percentage {
        case 0..<10:
            return baseSpeed * 0.7 // Slow start for battery safety
        case 10..<50:
            return baseSpeed * 1.0 // Full speed fast charging
        case 50..<80:
            return baseSpeed * 0.6 // Significant slowdown
        case 80..<90:
            return baseSpeed * 0.3 // Major throttling
        case 90..<95:
            return baseSpeed * 0.15 // Very slow
        case 95...100:
            return baseSpeed * 0.05 // Trickle charge
        default:
            return baseSpeed * 0.5
        }
    }
    
    var chargingTime: Double {
        guard let start = Double(startPercentage),
              let end = Double(endPercentage),
              start < end,
              start >= 0,
              end <= 100 else { return 0 }
        
        let batteryCapacity = phoneModel.batteryCapacity
        let stepSize = 1.0 // 1% increments for accuracy
        var totalTime = 0.0
        
        for percentage in stride(from: start, to: end, by: stepSize) {
            let currentSpeed = chargingSpeed(at: percentage)
            let energyForThisStep = (batteryCapacity * stepSize / 100) // mAh for this percentage
            let timeForThisStep = (energyForThisStep * 3.7) / (currentSpeed * 1000) // Convert to hours
            totalTime += timeForThisStep
        }
        
        return totalTime * 60 // Convert to minutes
    }
    
    var chargingBreakdown: [(percentage: Int, time: Double, speed: Double)] {
        guard let start = Double(startPercentage),
              let end = Double(endPercentage),
              start < end else { return [] }
        
        var breakdown: [(percentage: Int, time: Double, speed: Double)] = []
        let batteryCapacity = phoneModel.batteryCapacity
        var cumulativeTime = 0.0
        
        for percentage in stride(from: start, to: end, by: 10) {
            let currentSpeed = chargingSpeed(at: percentage)
            let energyFor10Percent = (batteryCapacity * 10 / 100) * 3.7 // Wh
            let timeFor10Percent = energyFor10Percent / (currentSpeed / 1000) / 60 // minutes
            cumulativeTime += timeFor10Percent
            
            breakdown.append((
                percentage: Int(percentage),
                time: cumulativeTime,
                speed: currentSpeed
            ))
        }
        
        return breakdown
    }
    
    var body: some View {
        CalculatorView(
            title: "iPhone Charge Time",
            description: "Calculate charging time for different iPhone models and chargers"
        ) {
            VStack(spacing: 20) {
                // Quick Action Buttons
                HStack(spacing: 8) {
                    QuickActionButton(
                        icon: "wand.and.stars.inverse",
                        title: "Example",
                        color: .blue
                    ) {
                        fillDemoDataAndCalculate()
                    }
                    
                    QuickActionButton(
                        icon: "trash",
                        title: "Clear",
                        color: .red
                    ) {
                        clearAllData()
                    }
                    
                    QuickActionButton(
                        icon: "info.circle",
                        title: "Info",
                        color: .gray
                    ) {
                        showInfo = true
                    }
                    
                    if showResults {
                        QuickActionButton(
                            icon: "square.and.arrow.up",
                            title: "Share",
                            color: .green
                        ) {
                            shareResults()
                        }
                    }
                }
                
                // iPhone Model Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("iPhone Model")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("iPhone Model", selection: $phoneModel) {
                        ForEach(iPhoneModel.allCases, id: \.self) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Text("Battery: \(Int(phoneModel.batteryCapacity)) mAh")
                        Spacer()
                        Text("Max: \(Int(phoneModel.maxChargingWatts))W")
                        Spacer()
                        Text(phoneModel.connector)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                // Charger Type Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Charger Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Charger Type", selection: $chargerType) {
                        ForEach(compatibleChargers, id: \.self) { charger in
                            Text(charger.rawValue).tag(charger)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Text("Output: \(Int(chargerType.maxWatts))W")
                        Spacer()
                        Text("Effective: \(String(format: "%.1f", effectiveChargingWatts))W")
                        Spacer()
                        if chargerType.isWireless {
                            Text("Wireless")
                                .foregroundColor(.blue)
                        } else {
                            Text("Wired")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                // Battery Percentage Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Charging Range")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        CalculatorInputField(
                            title: "Start %",
                            value: $startPercentage,
                            placeholder: "20",
                            keyboardType: .numberPad,
                            suffix: "%"
                        )
                        
                        CalculatorInputField(
                            title: "End %",
                            value: $endPercentage,
                            placeholder: "80",
                            keyboardType: .numberPad,
                            suffix: "%"
                        )
                    }
                    
                    Text("Tip: Charging 20-80% is optimal for battery health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Charge Time") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && chargingTime > 0 {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Charging Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        let formattedTime = chargingTime >= 60 ? 
                            "\(Int(chargingTime / 60))h \(Int(chargingTime.truncatingRemainder(dividingBy: 60)))m" :
                            "\(Int(chargingTime)) min"
                        let rangeText = "\(startPercentage)% → \(endPercentage)%"
                        
                        CalculatorResultCard(
                            title: "Charging Time",
                            value: formattedTime,
                            subtitle: rangeText,
                            color: .green
                        )
                        
                        // Quick Stats
                        HStack(spacing: 16) {
                            let startPct = Double(startPercentage) ?? 20
                            let endPct = Double(endPercentage) ?? 80
                            let energyAdded = (phoneModel.batteryCapacity * (endPct - startPct) / 100) * 3.7 / 1000
                            
                            CalculatorResultCard(
                                title: "Energy Added",
                                value: String(format: "%.1f Wh", energyAdded),
                                color: .blue
                            )
                            
                            let avgSpeed = effectiveChargingWatts * 0.7
                            
                            CalculatorResultCard(
                                title: "Avg Speed",
                                value: String(format: "%.1f W", avgSpeed),
                                color: .orange
                            )
                        }
                        
                        // Charging Curve Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Charging Speed by Battery Level")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach([(0, "0-10%", 0.7), (20, "10-50%", 1.0), (60, "50-80%", 0.6), (85, "80-90%", 0.3), (95, "90-100%", 0.1)], id: \.0) { item in
                                    let speedMultiplier = item.2
                                    let actualSpeed = effectiveChargingWatts * speedMultiplier
                                    
                                    HStack {
                                        Text(item.1)
                                            .font(.subheadline)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        // Visual speed bar
                                        let barColor: Color = speedMultiplier > 0.8 ? .green : speedMultiplier > 0.5 ? .yellow : .orange
                                        let barWidth = CGFloat(speedMultiplier * 80)
                                        
                                        HStack {
                                            Rectangle()
                                                .fill(barColor)
                                                .frame(width: barWidth, height: 8)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                            
                                            Spacer()
                                        }
                                        .frame(width: 80)
                                        
                                        Spacer()
                                        
                                        Text(String(format: "%.1fW", actualSpeed))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Comparison with Other Chargers
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Charger Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let comparisonChargers: [ChargerType] = [.lightning5W, .lightning20W, .lightning30W, .magsafe15W]
                            
                            VStack(spacing: 6) {
                                ForEach(comparisonChargers.filter { compatibleChargers.contains($0) }, id: \.self) { charger in
                                    let chargerWatts = min(charger.maxWatts * charger.efficiency, phoneModel.maxChargingWatts)
                                    let estimatedTime = chargingTime * (effectiveChargingWatts / chargerWatts)
                                    
                                    HStack {
                                        Text(charger.rawValue.components(separatedBy: " ").first ?? "")
                                            .font(.subheadline)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        if charger == chargerType {
                                            Text("Current")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.2))
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        } else {
                                            let timeText = estimatedTime >= 60 ? 
                                                "\(Int(estimatedTime / 60))h \(Int(estimatedTime.truncatingRemainder(dividingBy: 60)))m" :
                                                "\(Int(estimatedTime))min"
                                            
                                            Text(timeText)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Battery Health Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "battery.100")
                                    .foregroundColor(.green)
                                Text("Battery Health Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Charge between 20-80% for optimal battery longevity")
                                Text("• Avoid letting battery drop below 10% regularly")
                                Text("• Remove phone from case during fast charging to prevent overheating")
                                Text("• Use Optimized Battery Charging in iOS settings")
                                if chargerType.isWireless {
                                    Text("• Wireless charging generates more heat - position phone correctly")
                                        .foregroundColor(.orange)
                                }
                                if effectiveChargingWatts > 20 {
                                    Text("• Fast charging above 20W may generate more heat")
                                        .foregroundColor(.orange)
                                }
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
        }
        .sheet(isPresented: $showInfo) {
            iPhoneChargingInfoSheet()
        }
    }
    
    private func fillDemoData() {
        phoneModel = .iPhone15Pro
        chargerType = .lightning20W
        startPercentage = "20"
        endPercentage = "80"
        isDemoActive = true
    }
    
    private func fillDemoDataAndCalculate() {
        fillDemoData()
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        clearDemoData()
    }
    
    private func clearDemoData() {
        phoneModel = .iPhone15Pro
        chargerType = .lightning5W
        startPercentage = "20"
        endPercentage = "80"
        isDemoActive = false
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        iPhone Charging Time Results:
        Phone: \(phoneModel.rawValue)
        Charger: \(chargerType.rawValue)
        Charging \(startPercentage)% → \(endPercentage)%
        Time: \(chargingTime >= 60 ? "\(Int(chargingTime / 60))h \(Int(chargingTime.truncatingRemainder(dividingBy: 60)))m" : "\(Int(chargingTime)) min")
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

struct iPhoneChargingInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About iPhone Charging Time Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "How it works",
                            content: "This calculator estimates charging times based on iPhone battery capacity, charger output, and Apple's charging curve which slows down after 50% for battery health."
                        )
                        
                        InfoSection(
                            title: "Charging Speed Factors",
                            content: """
                            • Battery percentage (fastest 10-50%)
                            • Charger wattage and efficiency
                            • Phone temperature
                            • Background activity
                            • Cable quality
                            """
                        )
                        
                        InfoSection(
                            title: "Battery Health Tips",
                            content: """
                            • Charge between 20-80% when possible
                            • Avoid extreme temperatures
                            • Use certified chargers and cables
                            • Enable Optimized Battery Charging
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Charging Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    NavigationStack {
        iPhoneChargingTimeView()
    }
}