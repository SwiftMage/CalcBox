import SwiftUI

struct CalorieBurnView: View {
    @State private var weight = ""
    @State private var duration = ""
    @State private var selectedActivity = Activity.running
    @State private var intensity = Intensity.moderate
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: CalorieField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum CalorieField: CaseIterable {
        case weight, duration
    }
    
    enum Activity: String, CaseIterable {
        case running = "Running"
        case walking = "Walking"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case weightLifting = "Weight Lifting"
        case yoga = "Yoga"
        case dancing = "Dancing"
        case hiking = "Hiking"
        case basketball = "Basketball"
        case tennis = "Tennis"
        
        var baseMET: Double {
            switch self {
            case .running: return 8.0
            case .walking: return 3.8
            case .cycling: return 6.8
            case .swimming: return 8.3
            case .weightLifting: return 6.0
            case .yoga: return 2.5
            case .dancing: return 4.8
            case .hiking: return 6.0
            case .basketball: return 8.0
            case .tennis: return 7.3
            }
        }
    }
    
    enum Intensity: String, CaseIterable {
        case light = "Light"
        case moderate = "Moderate"
        case vigorous = "Vigorous"
        
        var multiplier: Double {
            switch self {
            case .light: return 0.8
            case .moderate: return 1.0
            case .vigorous: return 1.3
            }
        }
    }
    
    var caloriesBurned: Double {
        guard let bodyWeight = Double(weight),
              let exerciseDuration = Double(duration),
              bodyWeight > 0, exerciseDuration > 0 else { return 0 }
        
        let met = selectedActivity.baseMET * intensity.multiplier
        let weightInKg = bodyWeight * 0.453592 // Convert lbs to kg
        
        // Calories = MET × weight(kg) × time(hours)
        return met * weightInKg * (exerciseDuration / 60.0)
    }
    
    var caloriesPerMinute: Double {
        guard let exerciseDuration = Double(duration), exerciseDuration > 0 else { return 0 }
        return caloriesBurned / exerciseDuration
    }
    
    var equivalentFoods: [(food: String, amount: String)] {
        let calories = caloriesBurned
        return [
            ("Apples", "\(Int(calories / 95)) medium apples"),
            ("Bananas", "\(Int(calories / 105)) bananas"),
            ("Slices of bread", "\(Int(calories / 80)) slices"),
            ("Cookies", "\(Int(calories / 150)) chocolate chip cookies"),
            ("Pizza slices", "\(Int(calories / 285)) slices")
        ]
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Calorie Burning", description: "Exercise calorie calculator") {
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
                        title: "Body Weight",
                        value: $weight,
                        placeholder: "150",
                        suffix: "lbs",
                        icon: "figure.walk",
                        color: .blue,
                        keyboardType: .decimalPad,
                        helpText: "Your current body weight",
                        onNext: { focusNextField(.weight) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .weight)
                    .id(CalorieField.weight)
                    
                    ModernInputField(
                        title: "Exercise Duration",
                        value: $duration,
                        placeholder: "30",
                        suffix: "minutes",
                        icon: "timer",
                        color: .orange,
                        keyboardType: .numberPad,
                        helpText: "Total exercise time",
                        onPrevious: { focusPreviousField(.duration) },
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .duration)
                    .id(CalorieField.duration)
                
                // Activity Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Activity", selection: $selectedActivity) {
                        ForEach(Activity.allCases, id: \.self) { activity in
                            Text(activity.rawValue).tag(activity)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Intensity Selection
                SegmentedPicker(
                    title: "Intensity",
                    selection: $intensity,
                    options: Intensity.allCases.map { ($0, $0.rawValue) }
                )
                
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
                if showResults && caloriesBurned > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Calories Burned")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Total Calories Burned",
                            value: "\(Int(caloriesBurned)) cal",
                            subtitle: "\(selectedActivity.rawValue), \(intensity.rawValue) intensity",
                            color: .orange
                        )
                        
                        // Exercise Details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Calories per minute",
                                    value: String(format: "%.1f cal/min", caloriesPerMinute)
                                )
                                InfoRow(
                                    label: "Activity",
                                    value: "\(selectedActivity.rawValue) (\(intensity.rawValue))"
                                )
                                InfoRow(
                                    label: "Duration",
                                    value: "\(duration) minutes"
                                )
                                InfoRow(
                                    label: "Body Weight",
                                    value: "\(weight) lbs"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Food Equivalents
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Food Equivalents")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("You burned the equivalent of:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 6) {
                                ForEach(equivalentFoods.prefix(3), id: \.food) { food in
                                    InfoRow(
                                        label: food.food,
                                        value: food.amount
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Weekly Goal Context
                        if caloriesBurned > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "target")
                                        .foregroundColor(.blue)
                                    Text("Weekly Goal Progress")
                                        .font(.headline)
                                }
                                
                                let weeklyGoal = 2000.0 // Average weekly calorie burn goal
                                let progressPercent = min((caloriesBurned / weeklyGoal) * 100, 100)
                                
                                VStack(spacing: 4) {
                                    HStack {
                                        Text("Progress toward 2000 cal/week")
                                            .font(.caption)
                                        Spacer()
                                        Text(String(format: "%.1f%%", progressPercent))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    ProgressView(value: progressPercent, total: 100)
                                        .progressViewStyle(.linear)
                                        .tint(.blue)
                                }
                                
                                Text("\(Int(weeklyGoal - caloriesBurned)) calories remaining this week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBlue).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
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
            CalorieBurnInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: CalorieField) {
        let allFields = CalorieField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: CalorieField) {
        let allFields = CalorieField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        weight = "150"
        duration = "30"
        selectedActivity = .running
        intensity = .moderate
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        weight = ""
        duration = ""
        selectedActivity = .running
        intensity = .moderate
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Calorie Burn Calculator Results:
        Activity: \(selectedActivity.rawValue) (\(intensity.rawValue))
        Duration: \(duration) minutes
        Body Weight: \(weight) lbs
        Calories Burned: \(Int(caloriesBurned)) cal
        Calories per Minute: \(String(format: "%.1f", caloriesPerMinute)) cal/min
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

struct CalorieBurnInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Calorie Burn Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates calories burned during exercise based on activity type, intensity, duration, and body weight."
                        )
                        
                        InfoSection(
                            title: "Activity Intensities",
                            content: """
                            • Light: Casual pace, minimal exertion
                            • Moderate: Steady pace, some effort
                            • Vigorous: High intensity, challenging pace
                            """
                        )
                        
                        InfoSection(
                            title: "MET Values",
                            content: "Calculations use Metabolic Equivalent of Task (MET) values, which represent energy cost of activities relative to resting metabolic rate."
                        )
                        
                        InfoSection(
                            title: "Factors Affecting Burn",
                            content: """
                            • Body weight (heavier = more calories)
                            • Exercise intensity and duration
                            • Individual metabolism
                            • Fitness level and efficiency
                            • Environmental conditions
                            """
                        )
                        
                        InfoSection(
                            title: "Weekly Goals",
                            content: "CDC recommends 150+ minutes moderate or 75+ minutes vigorous exercise weekly, typically burning 1,000-2,000+ calories."
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Calorie Burn Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}