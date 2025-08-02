import SwiftUI

struct BMICalculatorView: View {
    @State private var weight = ""
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var heightCm = ""
    @State private var unitSystem = UnitSystem.imperial
    @State private var showResults = false
    @State private var age = ""
    @State private var gender = Gender.male
    
    enum UnitSystem: String, CaseIterable {
        case imperial = "Imperial"
        case metric = "Metric"
    }
    
    enum Gender: String, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    var bmi: Double {
        switch unitSystem {
        case .imperial:
            guard let w = Double(weight),
                  let feet = Double(heightFeet),
                  let inches = Double(heightInches),
                  w > 0, feet > 0 || inches > 0 else { return 0 }
            
            let totalInches = (feet * 12) + inches
            return (w * 703) / pow(totalInches, 2)
            
        case .metric:
            guard let w = Double(weight),
                  let cm = Double(heightCm),
                  w > 0, cm > 0 else { return 0 }
            
            let meters = cm / 100
            return w / pow(meters, 2)
        }
    }
    
    var bmiCategory: (name: String, color: Color, description: String) {
        switch bmi {
        case 0..<16:
            return ("Severe Thinness", .red, "Significantly underweight, health risks present")
        case 16..<17:
            return ("Moderate Thinness", .orange, "Moderately underweight")
        case 17..<18.5:
            return ("Mild Thinness", .yellow, "Mildly underweight")
        case 18.5..<25:
            return ("Normal", .green, "Healthy weight range")
        case 25..<30:
            return ("Overweight", .yellow, "Above ideal weight")
        case 30..<35:
            return ("Obese Class I", .orange, "Moderately obese")
        case 35..<40:
            return ("Obese Class II", .red, "Severely obese")
        default:
            return ("Obese Class III", .red, "Very severely obese")
        }
    }
    
    var idealWeightRange: (min: Double, max: Double) {
        let minBMI = 18.5
        let maxBMI = 24.9
        
        switch unitSystem {
        case .imperial:
            guard let feet = Double(heightFeet),
                  let inches = Double(heightInches) else { return (0, 0) }
            
            let totalInches = (feet * 12) + inches
            let minWeight = (minBMI * pow(totalInches, 2)) / 703
            let maxWeight = (maxBMI * pow(totalInches, 2)) / 703
            return (minWeight, maxWeight)
            
        case .metric:
            guard let cm = Double(heightCm) else { return (0, 0) }
            
            let meters = cm / 100
            let minWeight = minBMI * pow(meters, 2)
            let maxWeight = maxBMI * pow(meters, 2)
            return (minWeight, maxWeight)
        }
    }
    
    var weightToLoseOrGain: Double {
        guard let currentWeight = Double(weight) else { return 0 }
        
        if bmi < 18.5 {
            return idealWeightRange.min - currentWeight
        } else if bmi > 24.9 {
            return currentWeight - idealWeightRange.max
        } else {
            return 0
        }
    }
    
    var body: some View {
        CalculatorView(
            title: "Body Mass Index",
            description: "Calculate BMI and assess health risks"
        ) {
            VStack(spacing: 24) {
                // Unit System Selection
                SegmentedInputField(
                    title: "Unit System",
                    selection: $unitSystem,
                    options: UnitSystem.allCases.map { ($0, $0.rawValue) },
                    icon: "ruler.fill",
                    color: .blue
                )
                
                // Main Measurements
                GroupedInputFields(
                    title: "Body Measurements",
                    icon: "figure.stand",
                    color: .red
                ) {
                    if unitSystem == .imperial {
                        ModernInputField(
                            title: "Weight",
                            value: $weight,
                            placeholder: "150",
                            suffix: "lbs",
                            icon: "scalemass.fill",
                            color: .red,
                            helpText: "Your current body weight in pounds"
                        )
                        
                        HStack(spacing: 16) {
                            CompactInputField(
                                title: "Height (Feet)",
                                value: $heightFeet,
                                placeholder: "5",
                                suffix: "ft",
                                color: .blue
                            )
                            
                            CompactInputField(
                                title: "Height (Inches)",
                                value: $heightInches,
                                placeholder: "10",
                                suffix: "in",
                                color: .blue
                            )
                        }
                    } else {
                        ModernInputField(
                            title: "Weight",
                            value: $weight,
                            placeholder: "70",
                            suffix: "kg",
                            icon: "scalemass.fill",
                            color: .red,
                            helpText: "Your current body weight in kilograms"
                        )
                        
                        ModernInputField(
                            title: "Height",
                            value: $heightCm,
                            placeholder: "175",
                            suffix: "cm",
                            icon: "ruler.fill",
                            color: .blue,
                            helpText: "Your height in centimeters"
                        )
                    }
                }
                
                // Optional Information
                GroupedInputFields(
                    title: "Additional Information (Optional)",
                    icon: "person.fill",
                    color: .purple
                ) {
                    HStack(spacing: 16) {
                        CompactInputField(
                            title: "Age",
                            value: $age,
                            placeholder: "30",
                            suffix: "years",
                            color: .purple
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Picker("Gender", selection: $gender) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate BMI") {
                    withAnimation {
                        showResults = true
                    }
                }
                
                // Results
                if showResults && bmi > 0 {
                    VStack(spacing: 20) {
                        Divider()
                            .id("results")
                        
                        Text("Your BMI Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // BMI Score Card
                        VStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Your BMI",
                                value: String(format: "%.1f", bmi),
                                subtitle: bmiCategory.name,
                                color: bmiCategory.color
                            )
                            
                            // BMI Visual Scale
                            BMIScaleView(currentBMI: bmi)
                            
                            // Category Description
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(bmiCategory.color)
                                Text(bmiCategory.description)
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(bmiCategory.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Ideal Weight Range
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(.blue)
                                Text("Ideal Weight Range")
                                    .font(.headline)
                            }
                            
                            InfoRow(
                                label: "For your height",
                                value: unitSystem == .imperial ?
                                    "\(Int(idealWeightRange.min)) - \(Int(idealWeightRange.max)) lbs" :
                                    "\(Int(idealWeightRange.min)) - \(Int(idealWeightRange.max)) kg"
                            )
                            
                            if weightToLoseOrGain != 0 {
                                InfoRow(
                                    label: bmi > 24.9 ? "To reach ideal range" : "To reach healthy weight",
                                    value: bmi > 24.9 ?
                                        "Lose \(abs(Int(weightToLoseOrGain))) \(unitSystem == .imperial ? "lbs" : "kg")" :
                                        "Gain \(abs(Int(weightToLoseOrGain))) \(unitSystem == .imperial ? "lbs" : "kg")"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Health Risks
                        HealthRisksView(bmi: bmi)
                        
                        // Recommendations
                        RecommendationsView(bmi: bmi, age: age, gender: gender)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct BMIScaleView: View {
    let currentBMI: Double
    
    let ranges = [
        (range: 0..<18.5, color: Color.blue, label: "Underweight"),
        (range: 18.5..<25, color: Color.green, label: "Normal"),
        (range: 25..<30, color: Color.yellow, label: "Overweight"),
        (range: 30..<100, color: Color.red, label: "Obese")
    ]
    
    var markerPosition: CGFloat {
        let clampedBMI = min(max(currentBMI, 15), 35)
        return (clampedBMI - 15) / 20 // Maps 15-35 to 0-1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background gradient
                    LinearGradient(
                        colors: [.blue, .green, .yellow, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(height: 30)
                    
                    // Marker
                    VStack(spacing: 0) {
                        Triangle()
                            .fill(Color.primary)
                            .frame(width: 12, height: 8)
                            .rotationEffect(.degrees(180))
                        
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 2, height: 22)
                    }
                    .offset(x: geometry.size.width * markerPosition - 6)
                }
            }
            .frame(height: 30)
            
            // Scale labels
            HStack {
                Text("15")
                    .font(.caption)
                Spacer()
                Text("25")
                    .font(.caption)
                Spacer()
                Text("35")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct HealthRisksView: View {
    let bmi: Double
    
    var risks: [String] {
        if bmi < 18.5 {
            return [
                "Nutritional deficiency",
                "Osteoporosis",
                "Decreased immune function",
                "Fertility issues"
            ]
        } else if bmi >= 25 && bmi < 30 {
            return [
                "Increased risk of cardiovascular disease",
                "High blood pressure",
                "Type 2 diabetes risk",
                "Sleep apnea"
            ]
        } else if bmi >= 30 {
            return [
                "Heart disease",
                "Type 2 diabetes",
                "Certain cancers",
                "Stroke",
                "Sleep apnea",
                "Osteoarthritis"
            ]
        } else {
            return []
        }
    }
    
    var body: some View {
        if !risks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Associated Health Risks")
                        .font(.headline)
                }
                
                ForEach(risks, id: \.self) { risk in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                        Text(risk)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.systemOrange).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct RecommendationsView: View {
    let bmi: Double
    let age: String
    let gender: BMICalculatorView.Gender
    
    var recommendations: [String] {
        var tips: [String] = []
        
        if bmi < 18.5 {
            tips.append("Consult with a healthcare provider about healthy weight gain")
            tips.append("Focus on nutrient-dense foods")
            tips.append("Consider strength training to build muscle mass")
        } else if bmi >= 18.5 && bmi < 25 {
            tips.append("Maintain your healthy weight with balanced diet")
            tips.append("Continue regular physical activity")
            tips.append("Get regular health check-ups")
        } else if bmi >= 25 {
            tips.append("Aim for gradual weight loss (1-2 lbs per week)")
            tips.append("Increase physical activity to at least 150 minutes per week")
            tips.append("Focus on whole foods and portion control")
            tips.append("Consider consulting a nutritionist")
        }
        
        return tips
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.pink)
                Text("Recommendations")
                    .font(.headline)
            }
            
            ForEach(recommendations, id: \.self) { recommendation in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(recommendation)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Text("Always consult with healthcare professionals before making significant lifestyle changes.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGreen).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        BMICalculatorView()
    }
}