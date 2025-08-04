import SwiftUI
import Combine

enum CalorieField: CaseIterable {
    case age
    case height
    case weight
    case bodyFat
    
    var id: String {
        switch self {
        case .age: return "age"
        case .height: return "height"
        case .weight: return "weight"
        case .bodyFat: return "body-fat"
        }
    }
}

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    
    var icon: String {
        switch self {
        case .male: return "person.fill"
        case .female: return "person.fill"
        }
    }
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Heavy exercise 6-7 days/week"
        case .extremelyActive: return "Very heavy exercise, physical job"
        }
    }
    
    var icon: String {
        switch self {
        case .sedentary: return "figure.seated.side"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.run"
        case .veryActive: return "figure.strengthtraining.traditional"
        case .extremelyActive: return "flame.fill"
        }
    }
}

enum Goal: String, CaseIterable {
    case maintain = "Maintain Weight"
    case mildLoss = "Mild Weight Loss"
    case moderateLoss = "Moderate Weight Loss"
    case aggressiveLoss = "Aggressive Weight Loss"
    case mildGain = "Mild Weight Gain"
    case moderateGain = "Moderate Weight Gain"
    
    var calorieAdjustment: Double {
        switch self {
        case .maintain: return 0
        case .mildLoss: return -250      // 0.5 lb/week
        case .moderateLoss: return -500  // 1 lb/week
        case .aggressiveLoss: return -750 // 1.5 lb/week
        case .mildGain: return 250       // 0.5 lb/week
        case .moderateGain: return 500   // 1 lb/week
        }
    }
    
    var weeklyWeightChange: Double {
        switch self {
        case .maintain: return 0
        case .mildLoss: return -0.5
        case .moderateLoss: return -1.0
        case .aggressiveLoss: return -1.5
        case .mildGain: return 0.5
        case .moderateGain: return 1.0
        }
    }
    
    var color: Color {
        switch self {
        case .maintain: return .blue
        case .mildLoss, .moderateLoss, .aggressiveLoss: return .red
        case .mildGain, .moderateGain: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .maintain: return "equal.circle.fill"
        case .mildLoss, .moderateLoss, .aggressiveLoss: return "minus.circle.fill"
        case .mildGain, .moderateGain: return "plus.circle.fill"
        }
    }
}

enum Formula: String, CaseIterable {
    case mifflinStJeor = "Mifflin-St Jeor"
    case harrisBenedict = "Harris-Benedict"
    case katchMcArdle = "Katch-McArdle"
    
    var description: String {
        switch self {
        case .mifflinStJeor: return "Most accurate for general population"
        case .harrisBenedict: return "Traditional formula, slightly higher results"
        case .katchMcArdle: return "Most accurate for lean individuals (requires body fat %)"
        }
    }
    
    var requiresBodyFat: Bool {
        return self == .katchMcArdle
    }
}

struct DailyCaloriesView: View {
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var selectedGender = Gender.male
    @State private var selectedActivity = ActivityLevel.moderatelyActive
    @State private var selectedGoal = Goal.maintain
    @State private var selectedFormula = Formula.mifflinStJeor
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: CalorieField?
    @State private var keyboardHeight: CGFloat = 0
    
    private var calculationResults: CalorieResults {
        calculateCalories()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Daily Calorie Calculator", description: "Calculate your daily calorie needs") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Basic Information
                    GroupedInputFields(title: "Basic Information", icon: "person.crop.circle.fill", color: .blue) {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Age",
                                    value: $age,
                                    placeholder: "30",
                                    suffix: "years",
                                    icon: "calendar",
                                    color: .blue,
                                    keyboardType: .numberPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .age)
                                .id(CalorieField.age)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gender")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Picker("Gender", selection: $selectedGender) {
                                        ForEach(Gender.allCases, id: \.self) { gender in
                                            HStack {
                                                Image(systemName: gender.icon)
                                                Text(gender.rawValue)
                                            }
                                            .tag(gender)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                            
                            HStack(spacing: 16) {
                                ModernInputField(
                                    title: "Height",
                                    value: $height,
                                    placeholder: "70",
                                    suffix: "inches",
                                    icon: "ruler",
                                    color: .blue,
                                    keyboardType: .decimalPad,
                                    helpText: "5'10\" = 70 inches",
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .height)
                                .id(CalorieField.height)
                                
                                ModernInputField(
                                    title: "Weight",
                                    value: $weight,
                                    placeholder: "175",
                                    suffix: "lbs",
                                    icon: "scalemass",
                                    color: .blue,
                                    keyboardType: .decimalPad,
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .weight)
                                .id(CalorieField.weight)
                            }
                            
                            if selectedFormula.requiresBodyFat {
                                ModernInputField(
                                    title: "Body Fat Percentage",
                                    value: $bodyFat,
                                    placeholder: "15",
                                    suffix: "%",
                                    icon: "percent",
                                    color: .blue,
                                    keyboardType: .decimalPad,
                                    helpText: "Required for Katch-McArdle formula",
                                    onPrevious: { moveFocusToPrevious() },
                                    onNext: { moveFocusToNext() },
                                    onDone: { focusedField = nil },
                                    showPreviousButton: hasPreviousField(),
                                    showNextButton: hasNextField()
                                )
                                .focused($focusedField, equals: .bodyFat)
                                .id(CalorieField.bodyFat)
                            }
                        }
                    }
                    
                    // Activity Level
                    GroupedInputFields(title: "Activity Level", icon: "figure.run.circle.fill", color: .green) {
                        VStack(spacing: 12) {
                            ForEach(ActivityLevel.allCases, id: \.self) { activity in
                                Button(action: {
                                    selectedActivity = activity
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: activity.icon)
                                            .foregroundColor(selectedActivity == activity ? .white : .green)
                                            .font(.title3)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(activity.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(selectedActivity == activity ? .white : .primary)
                                            
                                            Text(activity.description)
                                                .font(.caption)
                                                .foregroundColor(selectedActivity == activity ? .white.opacity(0.8) : .secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedActivity == activity {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        selectedActivity == activity ? 
                                        Color.green : Color(.systemGray6)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Formula Selection
                    GroupedInputFields(title: "Calculation Method", icon: "function", color: .purple) {
                        VStack(spacing: 12) {
                            ForEach(Formula.allCases, id: \.self) { formula in
                                Button(action: {
                                    selectedFormula = formula
                                }) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(formula.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(selectedFormula == formula ? .white : .primary)
                                            
                                            Text(formula.description)
                                                .font(.caption)
                                                .foregroundColor(selectedFormula == formula ? .white.opacity(0.8) : .secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedFormula == formula {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        selectedFormula == formula ? 
                                        Color.purple : Color(.systemGray6)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Goal Selection
                    GroupedInputFields(title: "Your Goal", icon: "target", color: .orange) {
                        VStack(spacing: 12) {
                            ForEach(Goal.allCases, id: \.self) { goal in
                                Button(action: {
                                    selectedGoal = goal
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: goal.icon)
                                            .foregroundColor(selectedGoal == goal ? .white : goal.color)
                                            .font(.title3)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(goal.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(selectedGoal == goal ? .white : .primary)
                                            
                                            if goal.weeklyWeightChange != 0 {
                                                Text("\(goal.weeklyWeightChange > 0 ? "+" : "")\(String(format: "%.1f", goal.weeklyWeightChange)) lbs/week")
                                                    .font(.caption)
                                                    .foregroundColor(selectedGoal == goal ? .white.opacity(0.8) : .secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedGoal == goal {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        selectedGoal == goal ? 
                                        goal.color : Color(.systemGray6)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Calculate Button
                    Button(action: {
                        withAnimation {
                            showResults = true
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }) {
                        HStack {
                            Image(systemName: "calculator")
                            Text("Calculate Daily Calories")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!canCalculate)
                    
                    if showResults && canCalculate {
                        VStack(spacing: 20) {
                            // Main Calorie Result
                            CalculatorResultCard(
                                title: "Daily Calorie Target",
                                value: "\(Int(calculationResults.targetCalories)) cal",
                                subtitle: selectedGoal.rawValue,
                                color: selectedGoal.color
                            )
                            .id("results")
                            
                            // BMR and TDEE Breakdown
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    Text("Calorie Breakdown")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 12) {
                                    CalorieBreakdownRow(
                                        label: "BMR (Basal Metabolic Rate)",
                                        value: Int(calculationResults.bmr),
                                        description: "Calories burned at rest",
                                        color: .gray
                                    )
                                    
                                    CalorieBreakdownRow(
                                        label: "TDEE (Total Daily Energy)",
                                        value: Int(calculationResults.tdee),
                                        description: "BMR + activity calories",
                                        color: .blue
                                    )
                                    
                                    CalorieBreakdownRow(
                                        label: "Target Calories",
                                        value: Int(calculationResults.targetCalories),
                                        description: "TDEE adjusted for your goal",
                                        color: selectedGoal.color
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            // Goal-specific Information
                            if selectedGoal != .maintain {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: selectedGoal.icon)
                                            .foregroundColor(selectedGoal.color)
                                            .font(.title2)
                                        
                                        Text("Goal Information")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        if selectedGoal.weeklyWeightChange != 0 {
                                            HStack {
                                                Text("Weekly Weight Change:")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text("\(selectedGoal.weeklyWeightChange > 0 ? "+" : "")\(String(format: "%.1f", selectedGoal.weeklyWeightChange)) lbs")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(selectedGoal.color)
                                            }
                                            
                                            HStack {
                                                Text("Daily Calorie Deficit/Surplus:")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text("\(selectedGoal.calorieAdjustment > 0 ? "+" : "")\(Int(selectedGoal.calorieAdjustment)) cal")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(selectedGoal.color)
                                            }
                                        }
                                        
                                        // Time to goal estimates
                                        if abs(selectedGoal.weeklyWeightChange) > 0 {
                                            Divider()
                                            
                                            Text("Estimated timeline for 10 lb change:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            let weeksFor10Lbs = 10.0 / abs(selectedGoal.weeklyWeightChange)
                                            Text("\(String(format: "%.0f", weeksFor10Lbs)) weeks (\(String(format: "%.1f", weeksFor10Lbs / 4.33)) months)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedGoal.color)
                                        }
                                    }
                                }
                                .padding()
                                .background(selectedGoal.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            // Macronutrient Suggestions
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text("Macronutrient Guidelines")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                let macros = calculateMacros(targetCalories: calculationResults.targetCalories)
                                
                                VStack(spacing: 12) {
                                    MacroRow(
                                        name: "Protein",
                                        grams: macros.protein,
                                        calories: macros.protein * 4,
                                        percentage: 25,
                                        color: .red
                                    )
                                    
                                    MacroRow(
                                        name: "Carbohydrates",
                                        grams: macros.carbs,
                                        calories: macros.carbs * 4,
                                        percentage: 45,
                                        color: .orange
                                    )
                                    
                                    MacroRow(
                                        name: "Fat",
                                        grams: macros.fat,
                                        calories: macros.fat * 9,
                                        percentage: 30,
                                        color: .yellow
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
            DailyCaloriesInfoSheet()
        }
    }
    
    private var canCalculate: Bool {
        !age.isEmpty && !height.isEmpty && !weight.isEmpty &&
        (!selectedFormula.requiresBodyFat || !bodyFat.isEmpty)
    }
    
    private func calculateCalories() -> CalorieResults {
        let ageValue = Double(age) ?? 0
        let heightValue = Double(height) ?? 0 // inches
        let weightValue = Double(weight) ?? 0 // pounds
        let bodyFatValue = Double(bodyFat) ?? 0
        
        // Convert to metric for calculations
        let heightCm = heightValue * 2.54
        let weightKg = weightValue * 0.453592
        
        var bmr: Double
        
        switch selectedFormula {
        case .mifflinStJeor:
            if selectedGender == .male {
                bmr = 10 * weightKg + 6.25 * heightCm - 5 * ageValue + 5
            } else {
                bmr = 10 * weightKg + 6.25 * heightCm - 5 * ageValue - 161
            }
            
        case .harrisBenedict:
            if selectedGender == .male {
                bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * ageValue)
            } else {
                bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * ageValue)
            }
            
        case .katchMcArdle:
            let leanBodyMass = weightKg * (1 - bodyFatValue / 100)
            bmr = 370 + (21.6 * leanBodyMass)
        }
        
        let tdee = bmr * selectedActivity.multiplier
        let targetCalories = tdee + selectedGoal.calorieAdjustment
        
        return CalorieResults(
            bmr: bmr,
            tdee: tdee,
            targetCalories: max(1200, targetCalories), // Minimum safe calorie level
            formula: selectedFormula,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
    }
    
    private func calculateMacros(targetCalories: Double) -> (protein: Double, carbs: Double, fat: Double) {
        // Standard macro split: 25% protein, 45% carbs, 30% fat
        let proteinCalories = targetCalories * 0.25
        let carbCalories = targetCalories * 0.45
        let fatCalories = targetCalories * 0.30
        
        return (
            protein: proteinCalories / 4, // 4 calories per gram
            carbs: carbCalories / 4,      // 4 calories per gram
            fat: fatCalories / 9          // 9 calories per gram
        )
    }
    
    private func moveFocusToPrevious() {
        let allFields = CalorieField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .age) else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : allFields.count - 1
        focusedField = allFields[previousIndex]
    }
    
    private func moveFocusToNext() {
        let allFields = CalorieField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .age) else { return }
        let nextIndex = currentIndex < allFields.count - 1 ? currentIndex + 1 : 0
        focusedField = allFields[nextIndex]
    }
    
    private func hasPreviousField() -> Bool {
        let allFields = CalorieField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .age) else { return false }
        return currentIndex > 0
    }
    
    private func hasNextField() -> Bool {
        let allFields = CalorieField.allCases
        guard let currentIndex = allFields.firstIndex(of: focusedField ?? .age) else { return false }
        return currentIndex < allFields.count - 1
    }
    
    private func fillDemoDataAndCalculate() {
        age = "30"
        height = "70"
        weight = "175"
        bodyFat = "15"
        selectedGender = .male
        selectedActivity = .moderatelyActive
        selectedGoal = .mildLoss
        selectedFormula = .mifflinStJeor
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        age = ""
        height = ""
        weight = ""
        bodyFat = ""
        selectedGender = .male
        selectedActivity = .moderatelyActive
        selectedGoal = .maintain
        selectedFormula = .mifflinStJeor
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let results = calculationResults
        
        let shareText = """
        Daily Calorie Calculator Results:
        
        👤 Profile: \(selectedGender.rawValue), \(age) years old
        📏 Height: \(height)" | Weight: \(weight) lbs
        🏃 Activity: \(selectedActivity.rawValue)
        🎯 Goal: \(selectedGoal.rawValue)
        
        📊 CALORIE BREAKDOWN:
        BMR (at rest): \(Int(results.bmr)) calories
        TDEE (with activity): \(Int(results.tdee)) calories
        Target Calories: \(Int(results.targetCalories)) calories
        
        📈 GOAL DETAILS:
        Weekly Weight Change: \(selectedGoal.weeklyWeightChange > 0 ? "+" : "")\(String(format: "%.1f", selectedGoal.weeklyWeightChange)) lbs
        Daily Calorie Adjustment: \(selectedGoal.calorieAdjustment > 0 ? "+" : "")\(Int(selectedGoal.calorieAdjustment)) cal
        
        Formula Used: \(selectedFormula.rawValue)
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

struct CalorieResults {
    let bmr: Double
    let tdee: Double
    let targetCalories: Double
    let formula: Formula
    let activityLevel: ActivityLevel
    let goal: Goal
}

struct CalorieBreakdownRow: View {
    let label: String
    let value: Int
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(value) cal")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct MacroRow: View {
    let name: String
    let grams: Double
    let calories: Double
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(grams))g")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("\(Int(calories)) cal (\(percentage)%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DailyCaloriesInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Daily Calorie Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Calculates your Basal Metabolic Rate (BMR)
                            • Determines Total Daily Energy Expenditure (TDEE)
                            • Adjusts calories based on your specific goal
                            • Provides macronutrient breakdown guidelines
                            """
                        )
                        
                        InfoSection(
                            title: "Formula Differences",
                            content: """
                            • Mifflin-St Jeor: Most accurate for general population, newer formula
                            • Harris-Benedict: Traditional formula, tends to overestimate slightly
                            • Katch-McArdle: Most accurate for lean individuals, requires body fat %
                            """
                        )
                        
                        InfoSection(
                            title: "Activity Levels",
                            content: """
                            • Sedentary: Desk job, minimal exercise
                            • Lightly Active: Light exercise 1-3x/week
                            • Moderately Active: Moderate exercise 3-5x/week
                            • Very Active: Heavy exercise 6-7x/week
                            • Extremely Active: Very intense training + physical job
                            """
                        )
                        
                        InfoSection(
                            title: "Weight Change Guidelines",
                            content: """
                            • Safe weight loss: 1-2 lbs per week maximum
                            • 1 lb = 3,500 calories (500 cal deficit daily)
                            • Don't go below 1,200 calories (women) or 1,500 (men)
                            • Gradual changes are more sustainable
                            """
                        )
                        
                        InfoSection(
                            title: "Important Notes",
                            content: """
                            • These are estimates - individual results vary
                            • Metabolism can adapt over time
                            • Consider consulting a nutritionist for personalized advice
                            • Adjust based on your actual results over time
                            • Include strength training to preserve muscle mass
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Daily Calories Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}