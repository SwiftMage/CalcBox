import SwiftUI

struct ApplianceEnergyCostView: View {
    @State private var wattage = ""
    @State private var hoursPerDay = ""
    @State private var electricityRate = ""
    @State private var standbyWattage = ""
    @State private var includeStandby = false
    @State private var selectedAppliance: Appliance? = nil
    @State private var showAppliancePicker = false
    @State private var showResults = false
    
    struct Appliance: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let typicalWattage: Int
        let standbyWattage: Int?
        let icon: String
    }
    
    let commonAppliances = [
        // Kitchen
        Appliance(name: "Refrigerator", category: "Kitchen", typicalWattage: 150, standbyWattage: 5, icon: "refrigerator.fill"),
        Appliance(name: "Microwave", category: "Kitchen", typicalWattage: 1200, standbyWattage: 3, icon: "microwave.fill"),
        Appliance(name: "Electric Oven", category: "Kitchen", typicalWattage: 3000, standbyWattage: nil, icon: "oven.fill"),
        Appliance(name: "Dishwasher", category: "Kitchen", typicalWattage: 1800, standbyWattage: nil, icon: "dishwasher.fill"),
        Appliance(name: "Coffee Maker", category: "Kitchen", typicalWattage: 1000, standbyWattage: 1, icon: "cup.and.saucer.fill"),
        Appliance(name: "Toaster", category: "Kitchen", typicalWattage: 1200, standbyWattage: nil, icon: "rectangle.portrait.split.2x1.fill"),
        
        // Entertainment
        Appliance(name: "LED TV (55\")", category: "Entertainment", typicalWattage: 100, standbyWattage: 1, icon: "tv"),
        Appliance(name: "Gaming Console", category: "Entertainment", typicalWattage: 150, standbyWattage: 10, icon: "gamecontroller.fill"),
        Appliance(name: "Desktop Computer", category: "Entertainment", typicalWattage: 300, standbyWattage: 5, icon: "desktopcomputer"),
        Appliance(name: "Laptop", category: "Entertainment", typicalWattage: 65, standbyWattage: 1, icon: "laptopcomputer"),
        
        // Climate Control
        Appliance(name: "Central AC", category: "Climate", typicalWattage: 3500, standbyWattage: nil, icon: "air.conditioner.horizontal.fill"),
        Appliance(name: "Window AC", category: "Climate", typicalWattage: 1200, standbyWattage: nil, icon: "air.conditioner.vertical.fill"),
        Appliance(name: "Space Heater", category: "Climate", typicalWattage: 1500, standbyWattage: nil, icon: "heater.vertical.fill"),
        Appliance(name: "Ceiling Fan", category: "Climate", typicalWattage: 75, standbyWattage: nil, icon: "fan.ceiling.fill"),
        
        // Laundry
        Appliance(name: "Washing Machine", category: "Laundry", typicalWattage: 500, standbyWattage: 2, icon: "washer.fill"),
        Appliance(name: "Clothes Dryer", category: "Laundry", typicalWattage: 3000, standbyWattage: nil, icon: "dryer.fill"),
        
        // Other
        Appliance(name: "Hair Dryer", category: "Other", typicalWattage: 1800, standbyWattage: nil, icon: "wind"),
        Appliance(name: "Vacuum Cleaner", category: "Other", typicalWattage: 1400, standbyWattage: nil, icon: "fan.fill"),
        Appliance(name: "LED Light Bulb", category: "Other", typicalWattage: 10, standbyWattage: nil, icon: "lightbulb.fill"),
        Appliance(name: "Incandescent Bulb", category: "Other", typicalWattage: 60, standbyWattage: nil, icon: "lightbulb")
    ]
    
    var groupedAppliances: [String: [Appliance]] {
        Dictionary(grouping: commonAppliances) { $0.category }
    }
    
    // Calculations
    var activeKWhPerDay: Double {
        guard let watts = Double(wattage),
              let hours = Double(hoursPerDay),
              watts > 0, hours > 0 else { return 0 }
        return (watts * hours) / 1000
    }
    
    var standbyKWhPerDay: Double {
        guard includeStandby,
              let standby = Double(standbyWattage),
              let activeHours = Double(hoursPerDay),
              standby > 0, activeHours < 24 else { return 0 }
        let standbyHours = 24 - activeHours
        return (standby * standbyHours) / 1000
    }
    
    var totalKWhPerDay: Double {
        activeKWhPerDay + standbyKWhPerDay
    }
    
    var dailyCost: Double {
        guard let rate = Double(electricityRate) else { return 0 }
        return totalKWhPerDay * rate
    }
    
    var monthlyCost: Double {
        dailyCost * 30
    }
    
    var yearlyCost: Double {
        dailyCost * 365
    }
    
    var monthlyKWh: Double {
        totalKWhPerDay * 30
    }
    
    var yearlyKWh: Double {
        totalKWhPerDay * 365
    }
    
    var body: some View {
        CalculatorView(
            title: "Appliance Energy Cost",
            description: "Calculate electricity costs for any appliance"
        ) {
            VStack(spacing: 20) {
                // Appliance Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Appliance")
                        .font(.headline)
                    
                    Button(action: { showAppliancePicker = true }) {
                        HStack {
                            Image(systemName: selectedAppliance?.icon ?? "plug.fill")
                                .foregroundColor(.orange)
                            Text(selectedAppliance?.name ?? "Choose from common appliances")
                                .foregroundColor(selectedAppliance != nil ? .primary : .secondary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Manual Input
                VStack(alignment: .leading, spacing: 16) {
                    Text("Appliance Details")
                        .font(.headline)
                    
                    CalculatorInputField(
                        title: "Power Consumption",
                        value: $wattage,
                        placeholder: "100",
                        suffix: "watts"
                    )
                    
                    CalculatorInputField(
                        title: "Daily Usage",
                        value: $hoursPerDay,
                        placeholder: "8",
                        suffix: "hours/day"
                    )
                    
                    // Standby Power Toggle
                    Toggle(isOn: $includeStandby) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                            Text("Include Standby Power")
                        }
                    }
                    .tint(.purple)
                    
                    if includeStandby {
                        CalculatorInputField(
                            title: "Standby Power",
                            value: $standbyWattage,
                            placeholder: "5",
                            suffix: "watts"
                        )
                    }
                    
                    CalculatorInputField(
                        title: "Electricity Rate",
                        value: $electricityRate,
                        placeholder: "0.13",
                        suffix: "$/kWh"
                    )
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Energy Cost") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 20) {
                        Divider()
                        
                        Text("Energy Cost Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Cost Breakdown
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Daily Cost",
                                    value: NumberFormatter.formatCurrency(dailyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(totalKWhPerDay)) kWh",
                                    color: .blue
                                )
                                
                                CalculatorResultCard(
                                    title: "Monthly Cost",
                                    value: NumberFormatter.formatCurrency(monthlyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(monthlyKWh)) kWh",
                                    color: .green
                                )
                            }
                            
                            CalculatorResultCard(
                                title: "Yearly Cost",
                                value: NumberFormatter.formatCurrency(yearlyCost),
                                subtitle: "\(NumberFormatter.formatDecimal(yearlyKWh)) kWh",
                                color: .red
                            )
                        }
                        
                        // Energy Breakdown
                        if includeStandby && !standbyWattage.isEmpty {
                            EnergyBreakdownView(
                                activeKWh: activeKWhPerDay,
                                standbyKWh: standbyKWhPerDay,
                                activeHours: Double(hoursPerDay) ?? 0
                            )
                        }
                        
                        // Cost Comparison
                        CostComparisonWithOtherAppliances(
                            currentCost: yearlyCost,
                            currentAppliance: selectedAppliance?.name ?? "This appliance"
                        )
                        
                        // Energy Saving Tips
                        EnergySavingTips(
                            wattage: Double(wattage) ?? 0,
                            hoursPerDay: Double(hoursPerDay) ?? 0
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showAppliancePicker) {
            AppliancePickerView(
                appliances: commonAppliances,
                groupedAppliances: groupedAppliances,
                selectedAppliance: $selectedAppliance,
                onSelect: { appliance in
                    wattage = String(appliance.typicalWattage)
                    if let standby = appliance.standbyWattage {
                        standbyWattage = String(standby)
                        includeStandby = true
                    } else {
                        standbyWattage = ""
                        includeStandby = false
                    }
                    showAppliancePicker = false
                }
            )
        }
    }
}

struct EnergyBreakdownView: View {
    let activeKWh: Double
    let standbyKWh: Double
    let activeHours: Double
    
    var totalKWh: Double {
        activeKWh + standbyKWh
    }
    
    var activePercentage: Double {
        totalKWh > 0 ? (activeKWh / totalKWh) * 100 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Energy Breakdown")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                        Text("Active Use")
                            .font(.subheadline)
                    }
                    Text("\(NumberFormatter.formatDecimal(activeKWh)) kWh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(activePercentage))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 12, height: 12)
                        Text("Standby")
                            .font(.subheadline)
                    }
                    Text("\(NumberFormatter.formatDecimal(standbyKWh)) kWh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(100 - activePercentage))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            // Visual bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (activeKWh / totalKWh))
                    
                    Rectangle()
                        .fill(Color.purple)
                }
            }
            .frame(height: 20)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CostComparisonWithOtherAppliances: View {
    let currentCost: Double
    let currentAppliance: String
    
    let comparisons = [
        ("LED Bulb (8h/day)", 3.80),
        ("Laptop (8h/day)", 18.98),
        ("Refrigerator (24h/day)", 143.00),
        ("Central AC (8h/day)", 1022.00)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.orange)
                Text("Annual Cost Comparison")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(comparisons, id: \.0) { comparison in
                    HStack {
                        Text(comparison.0)
                            .font(.subheadline)
                        Spacer()
                        Text(NumberFormatter.formatCurrency(comparison.1))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(comparison.1 < currentCost ? .green : .red)
                    }
                }
                
                Divider()
                
                HStack {
                    Text(currentAppliance)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(NumberFormatter.formatCurrency(currentCost))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EnergySavingTips: View {
    let wattage: Double
    let hoursPerDay: Double
    
    var tips: [String] {
        var suggestions: [String] = []
        
        if wattage > 1000 {
            suggestions.append("Consider using this high-power appliance during off-peak hours if you have time-of-use rates")
        }
        
        if hoursPerDay > 8 {
            suggestions.append("Look for opportunities to reduce usage time or use timer controls")
        }
        
        suggestions.append("Unplug appliances when not in use to eliminate standby power consumption")
        suggestions.append("Consider upgrading to an ENERGY STAR certified model for better efficiency")
        
        return suggestions
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Energy Saving Tips")
                    .font(.headline)
            }
            
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(tip)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(Color(.systemYellow).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AppliancePickerView: View {
    let appliances: [ApplianceEnergyCostView.Appliance]
    let groupedAppliances: [String: [ApplianceEnergyCostView.Appliance]]
    @Binding var selectedAppliance: ApplianceEnergyCostView.Appliance?
    let onSelect: (ApplianceEnergyCostView.Appliance) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedAppliances.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(groupedAppliances[category] ?? []) { appliance in
                            Button(action: { onSelect(appliance) }) {
                                HStack {
                                    Image(systemName: appliance.icon)
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text(appliance.name)
                                            .font(.headline)
                                        HStack {
                                            Text("\(appliance.typicalWattage)W")
                                            if let standby = appliance.standbyWattage {
                                                Text("• \(standby)W standby")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedAppliance?.id == appliance.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Common Appliances")
            .navigationBarItems(trailing: Button("Cancel") {
                onSelect(selectedAppliance ?? appliances[0])
            })
        }
    }
}

#Preview {
    NavigationStack {
        ApplianceEnergyCostView()
    }
}