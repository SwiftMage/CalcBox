import SwiftUI

struct DrinkingCaloriesView: View {
    @State private var drinkType = DrinkType.beer
    @State private var quantity = "1"
    @State private var alcoholContent = ""
    @State private var servingSize = ""
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: DrinkField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum DrinkField: CaseIterable {
        case quantity, alcoholContent, servingSize
    }
    
    enum DrinkType: String, CaseIterable {
        case beer = "Beer"
        case wine = "Wine"
        case spirits = "Spirits/Liquor"
        case cocktail = "Cocktail"
        case custom = "Custom"
        
        var typicalABV: Double {
            switch self {
            case .beer: return 5.0
            case .wine: return 12.0
            case .spirits: return 40.0
            case .cocktail: return 15.0
            case .custom: return 0.0
            }
        }
        
        var typicalServing: Double { // in ml
            switch self {
            case .beer: return 355
            case .wine: return 148
            case .spirits: return 44
            case .cocktail: return 120
            case .custom: return 0
            }
        }
    }
    
    var abv: Double {
        if let custom = Double(alcoholContent) {
            return custom
        }
        return drinkType.typicalABV
    }
    
    var serving: Double {
        if let custom = Double(servingSize) {
            return custom
        }
        return drinkType.typicalServing
    }
    
    var alcoholGrams: Double {
        let alcoholVolume = serving * (abv / 100)
        return alcoholVolume * 0.789 // Density of alcohol g/ml
    }
    
    var alcoholCalories: Double {
        alcoholGrams * 7 // 7 calories per gram of alcohol
    }
    
    var totalCaloriesPerDrink: Double {
        let baseCalories = alcoholCalories
        let mixerCalories: Double
        
        switch drinkType {
        case .beer: mixerCalories = serving * 0.1 // ~0.1 cal/ml from carbs
        case .wine: mixerCalories = serving * 0.2 // ~0.2 cal/ml from sugars
        case .spirits: mixerCalories = 0 // Pure spirits
        case .cocktail: mixerCalories = 100 // Estimate for mixers
        case .custom: mixerCalories = 0
        }
        
        return baseCalories + mixerCalories
    }
    
    var totalCalories: Double {
        totalCaloriesPerDrink * (Double(quantity) ?? 1)
    }
    
    var equivalentExercise: [(activity: String, time: String)] {
        let calories = totalCalories
        return [
            ("Walking", "\(Int(calories / 4)) minutes"),
            ("Running", "\(Int(calories / 12)) minutes"),
            ("Cycling", "\(Int(calories / 8)) minutes"),
            ("Swimming", "\(Int(calories / 10)) minutes")
        ]
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Drinking Calories", description: "Alcohol calorie calculator") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Drink Type Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Drink Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Drink Type", selection: $drinkType) {
                            ForEach(DrinkType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: drinkType) { _ in
                            // Reset custom values when type changes
                            if drinkType != .custom {
                                alcoholContent = ""
                                servingSize = ""
                            }
                        }
                    }
                    
                    // Quantity
                    ModernInputField(
                        title: "Number of Drinks",
                        value: $quantity,
                        placeholder: "1",
                        suffix: "drinks",
                        icon: "wineglass.fill",
                        color: .purple,
                        keyboardType: .numberPad,
                        helpText: "Total number of drinks",
                        onNext: { focusNextField(.quantity) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .quantity)
                    .id(DrinkField.quantity)
                    
                    // Custom fields for custom type or override
                    VStack(spacing: 12) {
                        ModernInputField(
                            title: "Alcohol Content (\(drinkType == .custom ? "Required" : "Override"))",
                            value: $alcoholContent,
                            placeholder: String(format: "%.1f", drinkType.typicalABV),
                            suffix: "% ABV",
                            icon: "percent",
                            color: .orange,
                            keyboardType: .decimalPad,
                            helpText: drinkType == .custom ? "Enter alcohol percentage" : "Override default value",
                            onPrevious: { focusPreviousField(.alcoholContent) },
                            onNext: { focusNextField(.alcoholContent) },
                            onDone: { focusedField = nil }
                        )
                        .focused($focusedField, equals: .alcoholContent)
                        .id(DrinkField.alcoholContent)
                        
                        ModernInputField(
                            title: "Serving Size (\(drinkType == .custom ? "Required" : "Override"))",
                            value: $servingSize,
                            placeholder: String(format: "%.0f", drinkType.typicalServing),
                            suffix: "ml",
                            icon: "cup.and.saucer.fill",
                            color: .blue,
                            keyboardType: .decimalPad,
                            helpText: drinkType == .custom ? "Enter serving size" : "Override default value",
                            onPrevious: { focusPreviousField(.servingSize) },
                            onNext: { focusedField = nil },
                            onDone: { focusedField = nil },
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .servingSize)
                        .id(DrinkField.servingSize)
                    }
                
                // Calculate Button
                CalculatorButton(title: "Calculate Calories") {
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
                if showResults && totalCalories > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Calorie Analysis")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Calories",
                            value: "\(Int(totalCalories)) cal",
                            subtitle: "\(quantity) \(drinkType.rawValue.lowercased())\(Int(quantity) ?? 1 > 1 ? "s" : "")",
                            color: .orange
                        )
                        
                        // Per Drink Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Per Drink Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Calories from alcohol",
                                    value: "\(Int(alcoholCalories)) cal"
                                )
                                InfoRow(
                                    label: "Calories from other sources",
                                    value: "\(Int(totalCaloriesPerDrink - alcoholCalories)) cal"
                                )
                                InfoRow(
                                    label: "Total per drink",
                                    value: "\(Int(totalCaloriesPerDrink)) cal"
                                )
                                InfoRow(
                                    label: "Alcohol content",
                                    value: "\(String(format: "%.1f", abv))% ABV"
                                )
                                InfoRow(
                                    label: "Serving size",
                                    value: "\(String(format: "%.0f", serving)) ml"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Exercise Equivalent
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise to Burn Off Calories")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(equivalentExercise, id: \.activity) { exercise in
                                    InfoRow(
                                        label: exercise.activity,
                                        value: exercise.time
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Health Context
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Calorie Context")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let dailyCalories = 2000.0
                            let percentage = (totalCalories / dailyCalories) * 100
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Percentage of 2000-cal diet",
                                    value: String(format: "%.1f%%", percentage)
                                )
                                InfoRow(
                                    label: "Grams of pure alcohol",
                                    value: String(format: "%.1f g", alcoholGrams)
                                )
                            }
                            
                            if percentage > 15 {
                                Text("⚠️ These drinks represent a significant portion of daily calories")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .fontWeight(.medium)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Health Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Healthy Drinking Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Moderate drinking: 1 drink/day (women), 2 drinks/day (men)")
                                Text("• Alternate alcoholic drinks with water")
                                Text("• Eat before and while drinking to slow absorption")
                                Text("• Choose lower-calorie options like light beer or wine")
                                Text("• Be aware of mixer calories in cocktails")
                                Text("• Never drink and drive")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemRed).opacity(0.1))
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
            DrinkingCaloriesInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: DrinkField) {
        let allFields = DrinkField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: DrinkField) {
        let allFields = DrinkField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        drinkType = .beer
        quantity = "2"
        alcoholContent = ""
        servingSize = ""
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        drinkType = .beer
        quantity = "1"
        alcoholContent = ""
        servingSize = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Drinking Calories Calculator Results:
        Drink Type: \(drinkType.rawValue)
        Quantity: \(quantity) drink(s)
        Total Calories: \(Int(totalCalories)) cal
        Calories per Drink: \(Int(totalCaloriesPerDrink)) cal
        Alcohol Content: \(String(format: "%.1f", abv))% ABV
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

struct DrinkingCaloriesInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Drinking Calories Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates calories from alcoholic beverages based on alcohol content, serving size, and quantity."
                        )
                        
                        InfoSection(
                            title: "Calorie Sources",
                            content: """
                            • Alcohol: 7 calories per gram
                            • Carbohydrates and sugars in mixers
                            • Additional ingredients (cream, fruit, etc.)
                            """
                        )
                        
                        InfoSection(
                            title: "Health Guidelines",
                            content: """
                            • Moderate drinking: 1 drink/day (women), 2 drinks/day (men)
                            • One standard drink = 14g pure alcohol
                            • Alternate alcoholic drinks with water
                            • Eat before and while drinking
                            """
                        )
                        
                        InfoSection(
                            title: "Lower-Calorie Options",
                            content: """
                            • Light beer vs regular beer
                            • Wine vs sugary cocktails
                            • Spirits with low-cal mixers
                            • Limit frequency and quantity
                            """
                        )
                        
                        InfoSection(
                            title: "Important Note",
                            content: "Never drink and drive. This calculator is for informational purposes only and doesn't account for individual alcohol tolerance or health conditions."
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Drinking Calories Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}