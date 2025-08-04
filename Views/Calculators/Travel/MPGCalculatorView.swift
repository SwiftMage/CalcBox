import SwiftUI

struct MPGCalculatorView: View {
    @State private var milesDriven = ""
    @State private var gallonsUsed = ""
    @State private var fuelCost = ""
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: MPGField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum MPGField: CaseIterable {
        case milesDriven, gallonsUsed, fuelCost
    }
    
    var mpg: Double {
        guard let miles = Double(milesDriven),
              let gallons = Double(gallonsUsed),
              miles > 0, gallons > 0 else { return 0 }
        
        return miles / gallons
    }
    
    var costPerMile: Double {
        guard let cost = Double(fuelCost),
              let miles = Double(milesDriven),
              miles > 0, cost > 0 else { return 0 }
        
        return cost / miles
    }
    
    var costPerGallon: Double {
        guard let cost = Double(fuelCost),
              let gallons = Double(gallonsUsed),
              gallons > 0, cost > 0 else { return 0 }
        
        return cost / gallons
    }
    
    var efficiencyRating: (rating: String, color: Color, description: String) {
        switch mpg {
        case 0..<15:
            return ("Poor", .red, "Consider a more fuel-efficient vehicle")
        case 15..<25:
            return ("Below Average", .orange, "Room for improvement")
        case 25..<35:
            return ("Good", .yellow, "Above average fuel efficiency")
        case 35..<45:
            return ("Excellent", .green, "Very fuel efficient")
        default:
            return ("Outstanding", .blue, "Exceptional fuel efficiency")
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Miles Per Gallon", description: "Track fuel efficiency") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Input Fields
                    ModernInputField(
                        title: "Miles Driven",
                        value: $milesDriven,
                        placeholder: "300",
                        suffix: "miles",
                        icon: "car.fill",
                        color: .blue,
                        keyboardType: .decimalPad,
                        helpText: "Total distance traveled",
                        onNext: { focusNextField(.milesDriven) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .milesDriven)
                    .id(MPGField.milesDriven)
                    
                    ModernInputField(
                        title: "Gallons Used",
                        value: $gallonsUsed,
                        placeholder: "12",
                        suffix: "gallons",
                        icon: "fuelpump.fill",
                        color: .green,
                        keyboardType: .decimalPad,
                        helpText: "Total fuel consumed",
                        onPrevious: { focusPreviousField(.gallonsUsed) },
                        onNext: { focusNextField(.gallonsUsed) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .gallonsUsed)
                    .id(MPGField.gallonsUsed)
                    
                    ModernInputField(
                        title: "Total Fuel Cost (Optional)",
                        value: $fuelCost,
                        placeholder: "45.00",
                        prefix: "$",
                        icon: "dollarsign.circle.fill",
                        color: .orange,
                        keyboardType: .decimalPad,
                        helpText: "Cost for fuel analysis",
                        onPrevious: { focusPreviousField(.fuelCost) },
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .fuelCost)
                    .id(MPGField.fuelCost)
                
                // Calculate Button
                CalculatorButton(title: "Calculate MPG") {
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
                if showResults && mpg > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Fuel Efficiency Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main MPG Result
                        CalculatorResultCard(
                            title: "Miles Per Gallon",
                            value: String(format: "%.1f MPG", mpg),
                            subtitle: efficiencyRating.rating,
                            color: efficiencyRating.color
                        )
                        
                        // Efficiency Rating
                        HStack {
                            Image(systemName: "gauge.medium")
                                .foregroundColor(efficiencyRating.color)
                            Text(efficiencyRating.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(efficiencyRating.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Cost Analysis (if fuel cost is provided)
                        if !fuelCost.isEmpty && costPerMile > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cost Analysis")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Cost per Mile",
                                        value: NumberFormatter.formatCurrency(costPerMile),
                                        color: .orange
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Cost per Gallon",
                                        value: NumberFormatter.formatCurrency(costPerGallon),
                                        color: .purple
                                    )
                                }
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Total Distance",
                                        value: "\(milesDriven) miles"
                                    )
                                    InfoRow(
                                        label: "Total Fuel Used",
                                        value: "\(gallonsUsed) gallons"
                                    )
                                    InfoRow(
                                        label: "Total Fuel Cost",
                                        value: NumberFormatter.formatCurrency(Double(fuelCost) ?? 0)
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Comparison with national average
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let nationalAverage = 25.0
                            let comparison = mpg - nationalAverage
                            let isAboveAverage = comparison > 0
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Your MPG",
                                    value: String(format: "%.1f MPG", mpg)
                                )
                                InfoRow(
                                    label: "National Average",
                                    value: String(format: "%.1f MPG", nationalAverage)
                                )
                                InfoRow(
                                    label: "Difference",
                                    value: String(format: "%@%.1f MPG", isAboveAverage ? "+" : "", comparison)
                                )
                            }
                            
                            HStack {
                                Image(systemName: isAboveAverage ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(isAboveAverage ? .green : .red)
                                Text(isAboveAverage ? 
                                     "Above national average! Great fuel efficiency." :
                                     "Below national average. Consider fuel-saving driving habits.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            MPGInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: MPGField) {
        let allFields = MPGField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: MPGField) {
        let allFields = MPGField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        milesDriven = "350"
        gallonsUsed = "12.5"
        fuelCost = "45.00"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        milesDriven = ""
        gallonsUsed = ""
        fuelCost = ""
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        MPG Calculator Results:
        Miles Driven: \(milesDriven)
        Gallons Used: \(gallonsUsed)
        Miles Per Gallon: \(String(format: "%.1f MPG", mpg))
        Efficiency Rating: \(efficiencyRating.rating)
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

struct MPGInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About MPG Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator determines your vehicle's fuel efficiency in miles per gallon (MPG) and provides cost analysis."
                        )
                        
                        InfoSection(
                            title: "Efficiency Ratings",
                            content: """
                            • Poor: Less than 15 MPG
                            • Below Average: 15-25 MPG
                            • Good: 25-35 MPG
                            • Excellent: 35-45 MPG
                            • Outstanding: 45+ MPG
                            """
                        )
                        
                        InfoSection(
                            title: "Improving Fuel Efficiency",
                            content: """
                            • Maintain steady speeds and avoid rapid acceleration
                            • Keep tires properly inflated
                            • Remove excess weight from your vehicle
                            • Regular maintenance (oil changes, air filter)
                            • Use cruise control on highways
                            • Combine errands into one trip
                            """
                        )
                        
                        InfoSection(
                            title: "Cost Analysis",
                            content: "Enter fuel cost to see cost per mile and cost per gallon calculations, helping you budget for trips and compare vehicles."
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("MPG Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}