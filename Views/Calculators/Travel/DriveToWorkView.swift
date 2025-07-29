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
        dailyGallons * Double(workDaysPerWeek ?? "0") ?? 0 * 52 * 19.6
    }
    
    var electricCO2Emissions: Double {
        // Average US grid: 0.85 lbs CO2 per kWh
        dailyKWh * Double(workDaysPerWeek ?? "0") ?? 0 * 52 * 0.85
    }
    
    var body: some View {
        CalculatorView(
            title: "Drive to Work",
            description: "Compare commuting costs for gas and electric vehicles"
        ) {
            VStack(spacing: 20) {
                // Vehicle Type Selection
                SegmentedPicker(
                    title: "Vehicle Type",
                    selection: $vehicleType,
                    options: VehicleType.allCases.map { ($0, $0.rawValue) }
                )
                
                // Common Inputs
                VStack(spacing: 16) {
                    CalculatorInputField(
                        title: "Daily Commute Distance",
                        value: $dailyMiles,
                        placeholder: "30",
                        suffix: "miles"
                    )
                    
                    CalculatorInputField(
                        title: "Work Days Per Week",
                        value: $workDaysPerWeek,
                        placeholder: "5",
                        suffix: "days"
                    )
                }
                
                // Vehicle-specific inputs
                if vehicleType == .gas {
                    VStack(spacing: 16) {
                        CalculatorInputField(
                            title: "Miles Per Gallon (MPG)",
                            value: $mpg,
                            placeholder: "25",
                            suffix: "mpg"
                        )
                        
                        CalculatorInputField(
                            title: "Gas Price",
                            value: $gasPrice,
                            placeholder: "3.50",
                            suffix: "$/gallon"
                        )
                    }
                } else {
                    VStack(spacing: 16) {
                        CalculatorInputField(
                            title: "Vehicle Efficiency",
                            value: $milesPerKWh,
                            placeholder: "3.5",
                            suffix: "miles/kWh"
                        )
                        
                        CalculatorInputField(
                            title: "Electricity Rate",
                            value: $electricityRate,
                            placeholder: "0.13",
                            suffix: "$/kWh"
                        )
                        
                        CalculatorInputField(
                            title: "Charging Efficiency",
                            value: $chargingEfficiency,
                            placeholder: "90",
                            suffix: "%"
                        )
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Costs") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults {
                    VStack(spacing: 20) {
                        Divider()
                        
                        Text("Commute Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Cost Breakdown
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Daily Cost",
                                    value: NumberFormatter.formatCurrency(vehicleType == .gas ? dailyGasCost : dailyElectricCost),
                                    subtitle: vehicleType == .gas ? "\(NumberFormatter.formatDecimal(dailyGallons)) gallons" : "\(NumberFormatter.formatDecimal(dailyKWh)) kWh",
                                    color: .blue
                                )
                                
                                CalculatorResultCard(
                                    title: "Weekly Cost",
                                    value: NumberFormatter.formatCurrency(weeklyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(weeklyMiles)) miles",
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 16) {
                                CalculatorResultCard(
                                    title: "Monthly Cost",
                                    value: NumberFormatter.formatCurrency(monthlyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(monthlyMiles)) miles",
                                    color: .orange
                                )
                                
                                CalculatorResultCard(
                                    title: "Yearly Cost",
                                    value: NumberFormatter.formatCurrency(yearlyCost),
                                    subtitle: "\(NumberFormatter.formatDecimal(yearlyMiles)) miles",
                                    color: .red
                                )
                            }
                        }
                        
                        // Cost per mile
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cost Analysis")
                                .font(.headline)
                            
                            InfoRow(
                                label: "Cost per mile",
                                value: NumberFormatter.formatCurrency((vehicleType == .gas ? dailyGasCost : dailyElectricCost) / (Double(dailyMiles) ?? 1))
                            )
                            
                            if vehicleType == .gas {
                                InfoRow(
                                    label: "Fuel consumption",
                                    value: "\(NumberFormatter.formatDecimal(dailyGallons * Double(workDaysPerWeek ?? "0") ?? 0 * 52)) gallons/year"
                                )
                            } else {
                                InfoRow(
                                    label: "Energy consumption",
                                    value: "\(NumberFormatter.formatDecimal(dailyKWh * Double(workDaysPerWeek ?? "0") ?? 0 * 52)) kWh/year"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Environmental Impact
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("Environmental Impact")
                                    .font(.headline)
                            }
                            
                            InfoRow(
                                label: "Annual CO₂ Emissions",
                                value: "\(NumberFormatter.formatDecimal(vehicleType == .gas ? gasCO2Emissions : electricCO2Emissions)) lbs"
                            )
                            
                            if vehicleType == .electric {
                                Text("Electric vehicle emissions based on US average grid mix")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.green).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Comparison Tip
                        if vehicleType == .gas && !mpg.isEmpty && !gasPrice.isEmpty {
                            ComparisonTip(
                                gasCost: yearlyCost,
                                estimatedEVCost: calculateEstimatedEVCost()
                            )
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
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

struct ComparisonTip: View {
    let gasCost: Double
    let estimatedEVCost: Double
    
    var savings: Double {
        gasCost - estimatedEVCost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("EV Comparison")
                    .font(.headline)
            }
            
            Text("Switching to an electric vehicle could save you approximately \(NumberFormatter.formatCurrency(savings)) per year on fuel costs.")
                .font(.subheadline)
            
            Text("Based on average electricity rates and EV efficiency")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemYellow).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        DriveToWorkView()
    }
}