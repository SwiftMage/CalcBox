import SwiftUI

struct UnitConverterView: View {
    @State private var inputValue = ""
    @State private var selectedCategory = ConversionCategory.length
    @State private var fromUnit = 0
    @State private var toUnit = 1
    @State private var showResults = false
    
    enum ConversionCategory: String, CaseIterable {
        case length = "Length"
        case weight = "Weight"
        case temperature = "Temperature"
        case volume = "Volume"
        case area = "Area"
        case speed = "Speed"
        
        var units: [String] {
            switch self {
            case .length:
                return ["Millimeter", "Centimeter", "Meter", "Kilometer", "Inch", "Foot", "Yard", "Mile"]
            case .weight:
                return ["Gram", "Kilogram", "Ounce", "Pound", "Stone", "Ton (Metric)", "Ton (US)"]
            case .temperature:
                return ["Celsius", "Fahrenheit", "Kelvin"]
            case .volume:
                return ["Milliliter", "Liter", "Fluid Ounce", "Cup", "Pint", "Quart", "Gallon"]
            case .area:
                return ["Square Meter", "Square Kilometer", "Square Foot", "Square Yard", "Acre", "Hectare"]
            case .speed:
                return ["Meter/Second", "Kilometer/Hour", "Mile/Hour", "Knot", "Foot/Second"]
            }
        }
        
        var abbreviations: [String] {
            switch self {
            case .length:
                return ["mm", "cm", "m", "km", "in", "ft", "yd", "mi"]
            case .weight:
                return ["g", "kg", "oz", "lb", "st", "t", "ton"]
            case .temperature:
                return ["°C", "°F", "K"]
            case .volume:
                return ["ml", "L", "fl oz", "cup", "pt", "qt", "gal"]
            case .area:
                return ["m²", "km²", "ft²", "yd²", "acre", "ha"]
            case .speed:
                return ["m/s", "km/h", "mph", "kn", "ft/s"]
            }
        }
    }
    
    var convertedValue: Double {
        guard let input = Double(inputValue), input >= 0 else { return 0 }
        
        // Convert to base unit first, then to target unit
        let baseValue = convertToBase(value: input, fromUnit: fromUnit, category: selectedCategory)
        return convertFromBase(value: baseValue, toUnit: toUnit, category: selectedCategory)
    }
    
    private func convertToBase(value: Double, fromUnit: Int, category: ConversionCategory) -> Double {
        switch category {
        case .length:
            let factors = [0.001, 0.01, 1.0, 1000.0, 0.0254, 0.3048, 0.9144, 1609.344] // to meters
            return value * factors[fromUnit]
            
        case .weight:
            let factors = [0.001, 1.0, 0.0283495, 0.453592, 6.35029, 1000.0, 907.185] // to kg
            return value * factors[fromUnit]
            
        case .temperature:
            switch fromUnit {
            case 0: return value + 273.15 // Celsius to Kelvin
            case 1: return (value - 32) * 5/9 + 273.15 // Fahrenheit to Kelvin
            case 2: return value // Kelvin
            default: return value
            }
            
        case .volume:
            let factors = [0.001, 1.0, 0.0295735, 0.236588, 0.473176, 0.946353, 3.78541] // to liters
            return value * factors[fromUnit]
            
        case .area:
            let factors = [1.0, 1000000.0, 0.092903, 0.836127, 4046.86, 10000.0] // to square meters
            return value * factors[fromUnit]
            
        case .speed:
            let factors = [1.0, 0.277778, 0.44704, 0.514444, 0.3048] // to m/s
            return value * factors[fromUnit]
        }
    }
    
    private func convertFromBase(value: Double, toUnit: Int, category: ConversionCategory) -> Double {
        switch category {
        case .length:
            let factors = [1000.0, 100.0, 1.0, 0.001, 39.3701, 3.28084, 1.09361, 0.000621371] // from meters
            return value * factors[toUnit]
            
        case .weight:
            let factors = [1000.0, 1.0, 35.274, 2.20462, 0.157473, 0.001, 0.00110231] // from kg
            return value * factors[toUnit]
            
        case .temperature:
            switch toUnit {
            case 0: return value - 273.15 // Kelvin to Celsius
            case 1: return (value - 273.15) * 9/5 + 32 // Kelvin to Fahrenheit
            case 2: return value // Kelvin
            default: return value
            }
            
        case .volume:
            let factors = [1000.0, 1.0, 33.814, 4.22675, 2.11338, 1.05669, 0.264172] // from liters
            return value * factors[toUnit]
            
        case .area:
            let factors = [1.0, 0.000001, 10.7639, 1.19599, 0.000247105, 0.0001] // from square meters
            return value * factors[toUnit]
            
        case .speed:
            let factors = [1.0, 3.6, 2.23694, 1.94384, 3.28084] // from m/s
            return value * factors[toUnit]
        }
    }
    
    var body: some View {
        CalculatorView(title: "Unit Converter", description: "Convert between units") {
            VStack(spacing: 20) {
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conversion Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ConversionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: selectedCategory) { _ in
                        // Reset unit selections when category changes
                        fromUnit = 0
                        toUnit = min(1, selectedCategory.units.count - 1)
                    }
                }
                
                // Input Value
                CalculatorInputField(
                    title: "Value to Convert",
                    value: $inputValue,
                    placeholder: "100"
                )
                
                // From Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("From Unit", selection: $fromUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text("\(selectedCategory.units[index]) (\(selectedCategory.abbreviations[index]))").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // To Unit Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("To Unit", selection: $toUnit) {
                        ForEach(0..<selectedCategory.units.count, id: \.self) { index in
                            Text("\(selectedCategory.units[index]) (\(selectedCategory.abbreviations[index]))").tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Quick swap button
                Button("Swap Units") {
                    let temp = fromUnit
                    fromUnit = toUnit
                    toUnit = temp
                }
                .buttonStyle(.bordered)
            
                // Calculate Button
                CalculatorButton(title: "Convert") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && !inputValue.isEmpty {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("Conversion Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        VStack(spacing: 12) {
                            CalculatorResultCard(
                                title: "\(inputValue) \(selectedCategory.abbreviations[fromUnit])",
                                value: String(format: "%.6g", convertedValue),
                                subtitle: selectedCategory.abbreviations[toUnit],
                                color: .blue
                            )
                            
                            // Conversion equation
                            Text("\(inputValue) \(selectedCategory.units[fromUnit]) = \(String(format: "%.6g", convertedValue)) \(selectedCategory.units[toUnit])")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Common Conversions for this category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common \(selectedCategory.rawValue) Conversions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                ForEach(getCommonConversions(), id: \.0) { conversion in
                                    InfoRow(
                                        label: conversion.0,
                                        value: conversion.1
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Multiple unit results
                        if selectedCategory.units.count > 2 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(inputValue) \(selectedCategory.abbreviations[fromUnit]) in other units:")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 6) {
                                    ForEach(0..<selectedCategory.units.count, id: \.self) { unitIndex in
                                        if unitIndex != fromUnit {
                                            let convertedVal = convertFromBase(
                                                value: convertToBase(value: Double(inputValue) ?? 0, fromUnit: fromUnit, category: selectedCategory),
                                                toUnit: unitIndex,
                                                category: selectedCategory
                                            )
                                            InfoRow(
                                                label: selectedCategory.units[unitIndex],
                                                value: "\(String(format: "%.6g", convertedVal)) \(selectedCategory.abbreviations[unitIndex])"
                                            )
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func getCommonConversions() -> [(String, String)] {
        switch selectedCategory {
        case .length:
            return [
                ("1 inch", "2.54 cm"),
                ("1 foot", "0.305 meters"),
                ("1 mile", "1.609 km"),
                ("1 meter", "3.281 feet")
            ]
        case .weight:
            return [
                ("1 pound", "0.454 kg"),
                ("1 ounce", "28.35 grams"),
                ("1 kilogram", "2.205 pounds"),
                ("1 stone", "14 pounds")
            ]
        case .temperature:
            return [
                ("0°C", "32°F"),
                ("100°C", "212°F"),
                ("Room temp", "20°C / 68°F"),
                ("Body temp", "37°C / 98.6°F")
            ]
        case .volume:
            return [
                ("1 gallon", "3.785 liters"),
                ("1 liter", "1.057 quarts"),
                ("1 cup", "237 ml"),
                ("1 fluid ounce", "29.6 ml")
            ]
        case .area:
            return [
                ("1 acre", "4,047 m²"),
                ("1 hectare", "2.471 acres"),
                ("1 sq foot", "0.093 m²"),
                ("1 sq mile", "259 hectares")
            ]
        case .speed:
            return [
                ("60 mph", "96.6 km/h"),
                ("100 km/h", "62.1 mph"),
                ("1 knot", "1.852 km/h"),
                ("Sound (sea level)", "343 m/s")
            ]
        }
    }
    
    private func fillDemoDataAndCalculate() {
        selectedCategory = .length
        inputValue = "100"
        fromUnit = 0 // millimeter
        toUnit = 1   // centimeter
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        inputValue = ""
        selectedCategory = .length
        fromUnit = 0
        toUnit = 1
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Unit Converter Results:
        Category: \(selectedCategory.rawValue)
        \(inputValue) \(selectedCategory.units[fromUnit]) = \(String(format: "%.6g", convertedValue)) \(selectedCategory.units[toUnit])
        
        Conversion: \(inputValue) \(selectedCategory.abbreviations[fromUnit]) → \(String(format: "%.6g", convertedValue)) \(selectedCategory.abbreviations[toUnit])
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

struct UnitConverterInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Unit Converter")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: "This calculator converts values between different units of measurement across multiple categories including length, weight, temperature, volume, area, and speed."
                        )
                        
                        InfoSection(
                            title: "Available Categories",
                            content: """
                            • Length: millimeters, centimeters, meters, kilometers, inches, feet, yards, miles
                            • Weight: grams, kilograms, ounces, pounds, stones, metric tons, US tons
                            • Temperature: Celsius, Fahrenheit, Kelvin
                            • Volume: milliliters, liters, fluid ounces, cups, pints, quarts, gallons
                            • Area: square meters, square kilometers, square feet, square yards, acres, hectares
                            • Speed: meters/second, kilometers/hour, miles/hour, knots, feet/second
                            """
                        )
                        
                        InfoSection(
                            title: "How to use",
                            content: """
                            1. Select the category of units you want to convert
                            2. Enter the value you want to convert
                            3. Choose the 'from' unit and 'to' unit
                            4. Use the swap button to quickly reverse the conversion
                            5. View results and see conversions to other units in the same category
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • All conversions are precise and use standard conversion factors
                            • Temperature conversions account for offset differences (not just scaling)
                            • Use the 'All Units' section to see your value in every available unit
                            • Common conversions are provided for reference
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Unit Converter Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}