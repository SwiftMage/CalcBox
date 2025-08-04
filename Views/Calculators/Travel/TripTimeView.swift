import SwiftUI

struct TripTimeView: View {
    @State private var distance = ""
    @State private var speed = ""
    @State private var stops = ""
    @State private var stopDuration = "15"
    @State private var unitSystem = UnitSystem.miles
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: TripField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum TripField: CaseIterable {
        case distance, speed, stops, stopDuration
    }
    
    enum UnitSystem: String, CaseIterable {
        case miles = "Miles/MPH"
        case kilometers = "Kilometers/KPH"
    }
    
    var travelTimeHours: Double {
        guard let dist = Double(distance),
              let spd = Double(speed),
              dist > 0, spd > 0 else { return 0 }
        
        return dist / spd
    }
    
    var stopTimeHours: Double {
        guard let numStops = Double(stops),
              let duration = Double(stopDuration),
              numStops >= 0, duration >= 0 else { return 0 }
        
        return (numStops * duration) / 60.0
    }
    
    var totalTimeHours: Double {
        travelTimeHours + stopTimeHours
    }
    
    var formattedTime: (hours: Int, minutes: Int) {
        let totalMinutes = Int(totalTimeHours * 60)
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    var formattedTravelTime: (hours: Int, minutes: Int) {
        let totalMinutes = Int(travelTimeHours * 60)
        return (totalMinutes / 60, totalMinutes % 60)
    }
    
    var arrivalTime: Date {
        Calendar.current.date(byAdding: .minute, value: Int(totalTimeHours * 60), to: Date()) ?? Date()
    }
    
    var fuelEstimate: Double {
        guard let dist = Double(distance) else { return 0 }
        let avgMPG = unitSystem == .miles ? 25.0 : 10.0 // 25 MPG or 10 KM/L
        return dist / avgMPG
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Trip Time", description: "Estimate travel duration") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Unit System Selection
                    SegmentedPicker(
                        title: "Unit System",
                        selection: $unitSystem,
                        options: UnitSystem.allCases.map { ($0, $0.rawValue) }
                    )
                    
                    // Input Fields
                    ModernInputField(
                        title: "Distance",
                        value: $distance,
                        placeholder: "250",
                        suffix: unitSystem == .miles ? "miles" : "km",
                        icon: "map.fill",
                        color: .blue,
                        keyboardType: .decimalPad,
                        helpText: "Total trip distance",
                        onNext: { focusNextField(.distance) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .distance)
                    .id(TripField.distance)
                    
                    ModernInputField(
                        title: "Average Speed",
                        value: $speed,
                        placeholder: "65",
                        suffix: unitSystem == .miles ? "mph" : "km/h",
                        icon: "speedometer",
                        color: .green,
                        keyboardType: .decimalPad,
                        helpText: "Expected average speed",
                        onPrevious: { focusPreviousField(.speed) },
                        onNext: { focusNextField(.speed) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .speed)
                    .id(TripField.speed)
                    
                    ModernInputField(
                        title: "Number of Stops",
                        value: $stops,
                        placeholder: "2",
                        suffix: "stops",
                        icon: "pause.circle.fill",
                        color: .orange,
                        keyboardType: .numberPad,
                        helpText: "Planned rest/fuel stops",
                        onPrevious: { focusPreviousField(.stops) },
                        onNext: { focusNextField(.stops) },
                        onDone: { focusedField = nil }
                    )
                    .focused($focusedField, equals: .stops)
                    .id(TripField.stops)
                    
                    ModernInputField(
                        title: "Stop Duration",
                        value: $stopDuration,
                        placeholder: "15",
                        suffix: "minutes each",
                        icon: "timer",
                        color: .purple,
                        keyboardType: .numberPad,
                        helpText: "Time per stop",
                        onPrevious: { focusPreviousField(.stopDuration) },
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .stopDuration)
                    .id(TripField.stopDuration)
                
                // Calculate Button
                CalculatorButton(title: "Calculate Trip Time") {
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
                if showResults && totalTimeHours > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Trip Duration")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Trip Time",
                            value: "\(formattedTime.hours)h \(formattedTime.minutes)m",
                            subtitle: String(format: "%.1f hours", totalTimeHours),
                            color: .blue
                        )
                        
                        // Time Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Driving Time",
                                    value: "\(formattedTravelTime.hours)h \(formattedTravelTime.minutes)m"
                                )
                                
                                if stopTimeHours > 0 {
                                    InfoRow(
                                        label: "Stop Time",
                                        value: "\(Int(stopTimeHours * 60)) minutes"
                                    )
                                }
                                
                                InfoRow(
                                    label: "Distance",
                                    value: "\(distance) \(unitSystem == .miles ? "miles" : "km")"
                                )
                                
                                InfoRow(
                                    label: "Average Speed",
                                    value: "\(speed) \(unitSystem == .miles ? "mph" : "km/h")"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Arrival Time
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Departure & Arrival")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "If leaving now",
                                    value: DateFormatter.timeFormatter.string(from: Date())
                                )
                                InfoRow(
                                    label: "Estimated arrival",
                                    value: DateFormatter.timeFormatter.string(from: arrivalTime)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Additional Info
                        if unitSystem == .miles {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fuel Estimate")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Estimated fuel needed",
                                        value: String(format: "%.1f gallons", fuelEstimate)
                                    )
                                    InfoRow(
                                        label: "At $3.50/gallon",
                                        value: NumberFormatter.formatCurrency(fuelEstimate * 3.50)
                                    )
                                }
                                
                                Text("*Based on 25 MPG average")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemOrange).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Travel Tips")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Add 10-15% extra time for unexpected delays")
                                Text("• Check traffic conditions before departure")
                                Text("• Plan rest stops every 2 hours for safety")
                                if totalTimeHours > 4 {
                                    Text("• Consider breaking up long trips")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemYellow).opacity(0.1))
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
            TripTimeInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: TripField) {
        let allFields = TripField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: TripField) {
        let allFields = TripField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        distance = "250"
        speed = "65"
        stops = "2"
        stopDuration = "15"
        unitSystem = .miles
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        distance = ""
        speed = ""
        stops = ""
        stopDuration = "15"
        unitSystem = .miles
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Trip Time Calculator Results:
        Distance: \(distance) \(unitSystem == .miles ? "miles" : "km")
        Speed: \(speed) \(unitSystem == .miles ? "mph" : "km/h")
        Total Time: \(formattedTime.hours)h \(formattedTime.minutes)m
        Estimated Arrival: \(DateFormatter.timeFormatter.string(from: arrivalTime))
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

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct TripTimeInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Trip Time Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates total travel time including driving time and planned stops."
                        )
                        
                        InfoSection(
                            title: "Factors Included",
                            content: """
                            • Distance and average speed for driving time
                            • Number and duration of planned stops
                            • Arrival time estimation
                            • Fuel cost estimates (for miles)
                            """
                        )
                        
                        InfoSection(
                            title: "Travel Tips",
                            content: """
                            • Add 10-15% extra time for unexpected delays
                            • Check traffic conditions before departure
                            • Plan rest stops every 2 hours for safety
                            • Consider breaking up very long trips
                            • Account for weather conditions
                            """
                        )
                        
                        InfoSection(
                            title: "Accuracy Notes",
                            content: "Estimates assume consistent speed and don't account for traffic, weather, or construction delays. Use as a baseline and add buffer time."
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Trip Time Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}