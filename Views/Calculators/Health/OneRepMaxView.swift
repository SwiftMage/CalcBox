import SwiftUI

struct OneRepMaxView: View {
    @State private var weight = ""
    @State private var reps = ""
    @State private var selectedFormula = Formula.epley
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: OneRepMaxField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum OneRepMaxField: CaseIterable {
        case weight, reps
    }
    
    enum Formula: String, CaseIterable {
        case epley = "Epley"
        case brzycki = "Brzycki"
        case lander = "Lander"
        case oconner = "O'Conner"
        
        var description: String {
            switch self {
            case .epley: return "Most common formula (1RM = weight × (1 + reps/30))"
            case .brzycki: return "Good for lower rep ranges (1RM = weight × 36/(37-reps))"
            case .lander: return "Conservative estimate (1RM = weight × 100/(101.3-2.67123×reps))"
            case .oconner: return "Alternative formula (1RM = weight × (1 + reps/40))"
            }
        }
    }
    
    var oneRepMax: Double {
        guard let liftedWeight = Double(weight),
              let repetitions = Double(reps),
              liftedWeight > 0, repetitions > 0, repetitions <= 20 else { return 0 }
        
        switch selectedFormula {
        case .epley:
            return liftedWeight * (1 + repetitions / 30)
        case .brzycki:
            return liftedWeight * 36 / (37 - repetitions)
        case .lander:
            return liftedWeight * 100 / (101.3 - 2.67123 * repetitions)
        case .oconner:
            return liftedWeight * (1 + repetitions / 40)
        }
    }
    
    var allFormulas: [(formula: Formula, result: Double)] {
        Formula.allCases.map { formula in
            let tempFormula = selectedFormula
            let result: Double
            
            guard let liftedWeight = Double(weight),
                  let repetitions = Double(reps),
                  liftedWeight > 0, repetitions > 0, repetitions <= 20 else {
                return (formula, 0)
            }
            
            switch formula {
            case .epley:
                result = liftedWeight * (1 + repetitions / 30)
            case .brzycki:
                result = liftedWeight * 36 / (37 - repetitions)
            case .lander:
                result = liftedWeight * 100 / (101.3 - 2.67123 * repetitions)
            case .oconner:
                result = liftedWeight * (1 + repetitions / 40)
            }
            
            return (formula, result)
        }
    }
    
    var percentageTable: [(percentage: Int, weight: Double)] {
        let baseWeight = oneRepMax
        return [95, 90, 85, 80, 75, 70, 65, 60].map { percentage in
            (percentage, baseWeight * Double(percentage) / 100.0)
        }
    }
    
    var repRanges: [(range: String, percentage: String, purpose: String)] {
        return [
            ("1-3 reps", "90-100%", "Maximum Strength"),
            ("4-6 reps", "85-90%", "Strength & Power"),
            ("6-8 reps", "80-85%", "Strength & Size"),
            ("8-12 reps", "70-80%", "Muscle Growth"),
            ("12-15 reps", "65-70%", "Muscular Endurance"),
            ("15+ reps", "<65%", "Endurance & Conditioning")
        ]
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "One Rep Max", description: "Weight lifting calculator") {
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
                        title: "Weight Lifted",
                        value: $weight,
                        placeholder: "225",
                        suffix: "lbs",
                        icon: "scalemass.fill",
                        color: .red,
                        keyboardType: .decimalPad,
                        helpText: "Weight you can lift for the given repetitions",
                        onNext: { focusNextField(.weight) },
                        onDone: { focusedField = nil },
                        showPreviousButton: false
                    )
                    .focused($focusedField, equals: .weight)
                    .id(OneRepMaxField.weight)
                    
                    ModernInputField(
                        title: "Repetitions Completed",
                        value: $reps,
                        placeholder: "8",
                        suffix: "reps",
                        icon: "repeat.circle.fill",
                        color: .orange,
                        keyboardType: .numberPad,
                        helpText: "Number of repetitions completed at this weight",
                        onPrevious: { focusPreviousField(.reps) },
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .reps)
                    .id(OneRepMaxField.reps)
                
                // Formula Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calculation Formula")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Formula", selection: $selectedFormula) {
                        ForEach(Formula.allCases, id: \.self) { formula in
                            Text(formula.rawValue).tag(formula)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(selectedFormula.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate 1RM") {
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
                if showResults && oneRepMax > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("One Rep Max Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main Result
                        CalculatorResultCard(
                            title: "Estimated 1RM",
                            value: "\(Int(oneRepMax)) lbs",
                            subtitle: "Using \(selectedFormula.rawValue) formula",
                            color: .red
                        )
                        
                        // All Formula Comparison
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Formula Comparison")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(allFormulas, id: \.formula) { item in
                                    InfoRow(
                                        label: item.formula.rawValue,
                                        value: "\(Int(item.result)) lbs"
                                    )
                                }
                            }
                            
                            Text("Average: \(Int(allFormulas.map { $0.result }.reduce(0, +) / Double(allFormulas.count))) lbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Training Percentages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Percentages")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 6) {
                                ForEach(percentageTable, id: \.percentage) { item in
                                    InfoRow(
                                        label: "\(item.percentage)%",
                                        value: "\(Int(item.weight)) lbs"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Rep Ranges & Training Goals
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Guidelines")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(repRanges, id: \.range) { item in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.range)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text(item.percentage)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(item.purpose)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGreen).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Safety Warning
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Safety Guidelines")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Always use a spotter when attempting heavy lifts")
                                Text("• Warm up thoroughly before heavy lifting")
                                Text("• These are estimates - actual 1RM may vary")
                                Text("• Don't attempt 1RM frequently - reserve for testing")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemOrange).opacity(0.1))
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
            OneRepMaxInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: OneRepMaxField) {
        let allFields = OneRepMaxField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: OneRepMaxField) {
        let allFields = OneRepMaxField.allCases
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func fillDemoDataAndCalculate() {
        weight = "225"
        reps = "8"
        selectedFormula = .epley
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        weight = ""
        reps = ""
        selectedFormula = .epley
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        One Rep Max Results:
        Weight Lifted: \(weight) lbs for \(reps) reps
        Estimated 1RM: \(Int(oneRepMax)) lbs (\(selectedFormula.rawValue) formula)
        
        Training Percentages:
        95%: \(Int(oneRepMax * 0.95)) lbs
        90%: \(Int(oneRepMax * 0.90)) lbs
        85%: \(Int(oneRepMax * 0.85)) lbs
        80%: \(Int(oneRepMax * 0.80)) lbs
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

struct OneRepMaxInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About One Rep Max Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates your one-repetition maximum (1RM) - the maximum weight you can lift for a single repetition using proven formulas."
                        )
                        
                        InfoSection(
                            title: "Calculation Formulas",
                            content: """
                            • Epley: Most common (1RM = weight × (1 + reps/30))
                            • Brzycki: Good for lower reps (1RM = weight × 36/(37-reps))
                            • Lander: Conservative estimate
                            • O'Conner: Alternative method
                            """
                        )
                        
                        InfoSection(
                            title: "Training Guidelines",
                            content: """
                            • 1-3 reps: 90-100% 1RM (Max Strength)
                            • 4-6 reps: 85-90% 1RM (Strength & Power)
                            • 6-8 reps: 80-85% 1RM (Strength & Size)
                            • 8-12 reps: 70-80% 1RM (Muscle Growth)
                            • 12+ reps: <70% 1RM (Endurance)
                            """
                        )
                        
                        InfoSection(
                            title: "Safety Tips",
                            content: """
                            • Always use a spotter for heavy lifts
                            • Warm up thoroughly before testing
                            • These are estimates - actual results may vary
                            • Don't test 1RM frequently
                            • Consider proper form over maximum weight
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("One Rep Max Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}