import SwiftUI

struct SleepDebtCalculatorView: View {
    @State private var targetSleepHours = "8"
    @State private var actualSleepHours = ""
    @State private var daysTracked = "7"
    @State private var selectedChronotype = Chronotype.average
    @State private var hasWeekendCatchup = false
    @State private var weekendExtraHours = "1"
    
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: FocusableField?
    
    enum FocusableField: Hashable {
        case targetSleepHours, actualSleepHours, daysTracked, weekendExtraHours
    }
    
    enum Chronotype: String, CaseIterable {
        case earlyBird = "Early Bird"
        case average = "Average"
        case nightOwl = "Night Owl"
        
        var description: String {
            switch self {
            case .earlyBird: return "Prefer sleeping early (9-10 PM)"
            case .average: return "Standard sleep schedule (10-11 PM)"
            case .nightOwl: return "Prefer staying up late (11+ PM)"
            }
        }
        
        var recoveryMultiplier: Double {
            switch self {
            case .earlyBird: return 1.1
            case .average: return 1.0
            case .nightOwl: return 0.9
            }
        }
    }
    
    private let category = CalcBoxColors.CategoryColors.health
    
    // MARK: - Calculations
    
    private var dailySleepDeficit: Double {
        guard let target = Double(targetSleepHours),
              let actual = Double(actualSleepHours) else { return 0 }
        return max(0, target - actual)
    }
    
    private var totalSleepDebt: Double {
        guard let days = Double(daysTracked) else { return 0 }
        var totalDeficit = dailySleepDeficit * days
        
        // Account for weekend catch-up sleep
        if hasWeekendCatchup {
            let weekends = days / 7.0 * 2.0 // Number of weekend days
            let catchupHours = Double(weekendExtraHours) ?? 0
            totalDeficit = max(0, totalDeficit - (weekends * catchupHours))
        }
        
        return totalDeficit
    }
    
    private var recoveryTimeNeeded: Double {
        // It takes longer to recover from sleep debt than to accumulate it
        return totalSleepDebt * 1.5 * selectedChronotype.recoveryMultiplier
    }
    
    private var recoveryDays: Double {
        guard let target = Double(targetSleepHours) else { return 0 }
        return recoveryTimeNeeded / target
    }
    
    private var performanceImpact: Double {
        // Performance decreases roughly 10% per hour of sleep debt up to 50%
        return min(0.5, totalSleepDebt * 0.1)
    }
    
    private var canCalculate: Bool {
        !targetSleepHours.isEmpty && !actualSleepHours.isEmpty && !daysTracked.isEmpty
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "bed.double.fill")
                                .font(.title2)
                                .foregroundColor(category.primary)
                                .frame(width: 32, height: 32)
                                .background(category.light)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sleep Debt Calculator")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(CalcBoxColors.Text.primary)
                                
                                Text("Track sleep deficit and plan recovery")
                                    .font(.subheadline)
                                    .foregroundColor(CalcBoxColors.Text.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions
                    QuickActionButtonRow(
                        onExample: fillExampleData,
                        onClear: clearAllData,
                        onInfo: { showInfo = true },
                        onShare: shareResults,
                        showShare: showResults
                    )
                    .padding(.horizontal, 20)
                    
                    // Sleep Schedule Input
                    GroupedInputFields(
                        title: "Sleep Schedule",
                        icon: "clock.fill",
                        color: category.primary
                    ) {
                        ModernInputField(
                            title: "Target Sleep Hours",
                            value: $targetSleepHours,
                            placeholder: "8",
                            suffix: "hours/night",
                            icon: "target",
                            color: category.primary,
                            helpText: "Recommended: 7-9 hours for adults",
                            onPrevious: { focusPrevious() },
                            onNext: { focusNext() },
                            onDone: { calculate() }
                        )
                        .focused($focusedField, equals: .targetSleepHours)
                        
                        ModernInputField(
                            title: "Actual Sleep Hours",
                            value: $actualSleepHours,
                            placeholder: "6.5",
                            suffix: "hours/night",
                            icon: "clock.badge.checkmark",
                            color: category.primary,
                            helpText: "Average sleep you actually get",
                            onPrevious: { focusPrevious() },
                            onNext: { focusNext() },
                            onDone: { calculate() }
                        )
                        .focused($focusedField, equals: .actualSleepHours)
                        
                        ModernInputField(
                            title: "Days Tracked",
                            value: $daysTracked,
                            placeholder: "7",
                            suffix: "days",
                            icon: "calendar.badge.clock",
                            color: category.primary,
                            helpText: "Period to analyze sleep debt",
                            onPrevious: { focusPrevious() },
                            onNext: { focusNext() },
                            onDone: { calculate() }
                        )
                        .focused($focusedField, equals: .daysTracked)
                    }
                    .padding(.horizontal, 20)
                    
                    // Sleep Profile
                    GroupedInputFields(
                        title: "Sleep Profile",
                        icon: "person.crop.circle.fill",
                        color: category.primary
                    ) {
                        SegmentedInputField(
                            title: "Chronotype",
                            selection: $selectedChronotype,
                            options: Chronotype.allCases.map { ($0, $0.rawValue) },
                            icon: "moon.stars.fill",
                            color: category.primary
                        )
                        
                        ToggleInputField(
                            title: "Weekend Catch-up Sleep",
                            subtitle: "Do you sleep extra on weekends?",
                            isOn: $hasWeekendCatchup,
                            icon: "calendar.badge.plus",
                            color: category.primary
                        )
                        
                        if hasWeekendCatchup {
                            ModernInputField(
                                title: "Extra Weekend Hours",
                                value: $weekendExtraHours,
                                placeholder: "1",
                                suffix: "hours",
                                icon: "plus.circle.fill",
                                color: category.primary,
                                helpText: "Additional sleep on weekends",
                                onPrevious: { focusPrevious() },
                                onNext: { focusNext() },
                                onDone: { calculate() }
                            )
                            .focused($focusedField, equals: .weekendExtraHours)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasWeekendCatchup)
                    
                    // Calculate Button
                    CalculatorButton(
                        title: "Analyze Sleep Debt",
                        category: category,
                        isDisabled: !canCalculate
                    ) {
                        calculate()
                    }
                    .padding(.horizontal, 20)
                    
                    // Results
                    if showResults {
                        VStack(spacing: 24) {
                            // Sleep Debt Overview
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Daily Sleep Deficit",
                                        value: NumberFormatter.formatDecimal(dailySleepDeficit, precision: 1) + " hrs",
                                        subtitle: totalSleepDebt > 0 ? "Accumulating debt" : "No deficit",
                                        color: dailySleepDeficit > 0 ? .orange : category.primary,
                                        category: category
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Total Sleep Debt",
                                        value: NumberFormatter.formatDecimal(totalSleepDebt, precision: 1) + " hrs",
                                        subtitle: "Over \(daysTracked) days",
                                        color: totalSleepDebt > 4 ? .red : (totalSleepDebt > 2 ? .orange : category.primary),
                                        category: category
                                    )
                                }
                                
                                HStack(spacing: 16) {
                                    CalculatorResultCard(
                                        title: "Recovery Time",
                                        value: NumberFormatter.formatDecimal(recoveryTimeNeeded, precision: 1) + " hrs",
                                        subtitle: "\(NumberFormatter.formatDecimal(recoveryDays, precision: 1)) nights to recover",
                                        color: category.secondary,
                                        category: category
                                    )
                                    
                                    CalculatorResultCard(
                                        title: "Performance Impact",
                                        value: NumberFormatter.formatPercent(performanceImpact * 100),
                                        subtitle: performanceImpact > 0.2 ? "Significant impact" : "Manageable",
                                        color: performanceImpact > 0.2 ? .red : .green,
                                        category: category
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .id("results")
                            
                            // Sleep Health Analysis
                            InfoSection(
                                title: buildHealthStatusTitle(),
                                content: buildHealthAnalysis(),
                                accentColor: getSleepHealthColor()
                            )
                            .padding(.horizontal, 20)
                            
                            // Recovery Recommendations
                            InfoSection(
                                title: "💤 Recovery Plan",
                                content: buildRecoveryPlan(),
                                accentColor: category.primary
                            )
                            .padding(.horizontal, 20)
                            
                            // Sleep Science Tips
                            InfoSection(
                                title: "🧠 Sleep Science",
                                content: buildSleepScienceTips(),
                                accentColor: .blue
                            )
                            .padding(.horizontal, 20)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
            }
            .background(CalcBoxColors.Gradients.categoryBackground(category).ignoresSafeArea())
            .navigationTitle("Sleep Debt")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showInfo) {
                SleepDebtInfoSheet()
            }
            .onChange(of: focusedField) { newValue in
                if let field = newValue {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
            }
            .onChange(of: showResults) { newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                        proxy.scrollTo("results", anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func calculate() {
        focusedField = nil
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showResults = true
        }
    }
    
    private func fillExampleData() {
        targetSleepHours = "8"
        actualSleepHours = "6.5"
        daysTracked = "14"
        selectedChronotype = .average
        hasWeekendCatchup = true
        weekendExtraHours = "1.5"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            calculate()
        }
    }
    
    private func clearAllData() {
        targetSleepHours = ""
        actualSleepHours = ""
        daysTracked = ""
        selectedChronotype = .average
        hasWeekendCatchup = false
        weekendExtraHours = "1"
        focusedField = nil
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        💤 My Sleep Debt Analysis
        
        Target sleep: \(targetSleepHours) hours/night
        Actual sleep: \(actualSleepHours) hours/night
        Daily deficit: \(NumberFormatter.formatDecimal(dailySleepDeficit, precision: 1)) hours
        
        Total sleep debt: \(NumberFormatter.formatDecimal(totalSleepDebt, precision: 1)) hours
        Recovery needed: \(NumberFormatter.formatDecimal(recoveryTimeNeeded, precision: 1)) hours
        Performance impact: \(NumberFormatter.formatPercent(performanceImpact * 100))
        
        Chronotype: \(selectedChronotype.rawValue)
        
        Calculated with CalcBox
        """
        
        let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    // MARK: - Focus Management
    
    private func focusPrevious() {
        switch focusedField {
        case .actualSleepHours:
            focusedField = .targetSleepHours
        case .daysTracked:
            focusedField = .actualSleepHours
        case .weekendExtraHours:
            focusedField = .daysTracked
        default:
            break
        }
    }
    
    private func focusNext() {
        switch focusedField {
        case .targetSleepHours:
            focusedField = .actualSleepHours
        case .actualSleepHours:
            focusedField = .daysTracked
        case .daysTracked:
            if hasWeekendCatchup {
                focusedField = .weekendExtraHours
            } else {
                focusedField = nil
            }
        case .weekendExtraHours:
            focusedField = nil
        default:
            break
        }
    }
    
    // MARK: - Content Builders
    
    private func buildHealthStatusTitle() -> String {
        if totalSleepDebt == 0 {
            return "✅ Excellent Sleep Health"
        } else if totalSleepDebt < 2 {
            return "😊 Good Sleep Health"
        } else if totalSleepDebt < 5 {
            return "⚠️ Moderate Sleep Debt"
        } else if totalSleepDebt < 10 {
            return "🔴 High Sleep Debt"
        } else {
            return "🚨 Critical Sleep Debt"
        }
    }
    
    private func getSleepHealthColor() -> Color {
        if totalSleepDebt == 0 {
            return .green
        } else if totalSleepDebt < 2 {
            return category.primary
        } else if totalSleepDebt < 5 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func buildHealthAnalysis() -> String {
        var analysis = ""
        
        if totalSleepDebt == 0 {
            analysis = "Congratulations! You're maintaining excellent sleep hygiene with no accumulated sleep debt. Your cognitive performance and physical health are optimally supported."
        } else if totalSleepDebt < 2 {
            analysis = "You have minimal sleep debt that's easily manageable. This small deficit shouldn't significantly impact your daily performance."
        } else if totalSleepDebt < 5 {
            analysis = "You have moderate sleep debt that may be affecting your cognitive performance, mood, and immune function. Consider prioritizing sleep recovery."
        } else if totalSleepDebt < 10 {
            analysis = "Your sleep debt is at concerning levels. This deficit is likely impacting your decision-making, reaction times, and overall health. Recovery should be a priority."
        } else {
            analysis = "Critical sleep debt detected. This level of deficit significantly impairs cognitive function and increases health risks. Immediate attention to sleep recovery is essential."
        }
        
        analysis += "\n\nPerformance Impact: "
        if performanceImpact < 0.1 {
            analysis += "Minimal impact on daily performance."
        } else if performanceImpact < 0.2 {
            analysis += "Noticeable reduction in focus and reaction time."
        } else if performanceImpact < 0.3 {
            analysis += "Significant impairment in cognitive performance and decision-making."
        } else {
            analysis += "Severe performance degradation affecting safety and productivity."
        }
        
        return analysis
    }
    
    private func buildRecoveryPlan() -> String {
        if totalSleepDebt == 0 {
            return """
            🎯 Maintain your current excellent sleep schedule
            • Continue getting \(targetSleepHours) hours of sleep nightly
            • Keep consistent sleep and wake times
            • Maintain good sleep hygiene practices
            """
        }
        
        let extraHoursNeeded = recoveryTimeNeeded / recoveryDays
        
        return """
        🎯 Recovery Strategy (\(selectedChronotype.rawValue) chronotype):
        
        • Add \(NumberFormatter.formatDecimal(extraHoursNeeded, precision: 1)) extra hours of sleep per night
        • Target \(NumberFormatter.formatDecimal(Double(targetSleepHours) ?? 8 + extraHoursNeeded, precision: 1)) hours total sleep during recovery
        • Recovery timeline: \(NumberFormatter.formatDecimal(recoveryDays, precision: 0)) nights
        
        💡 Quick Recovery Tips:
        • Go to bed 30-60 minutes earlier
        • Avoid caffeine after 2 PM
        • Limit screen time 1 hour before bed
        • Keep your bedroom cool (65-68°F)
        • Consider strategic naps (20-30 minutes max)
        """
    }
    
    private func buildSleepScienceTips() -> String {
        return """
        🔬 Understanding Sleep Debt:
        
        • Sleep debt accumulates faster than it's repaid - recovery takes 1.5x longer
        • \(selectedChronotype.description.lowercased()) people recover at different rates
        • Each hour of sleep debt reduces performance by ~10%
        • Weekend catch-up sleep helps but doesn't fully eliminate weekday deficits
        
        🧬 Sleep Stages Matter:
        • Deep sleep (25% of night) is crucial for physical recovery
        • REM sleep (25% of night) consolidates memories and learning
        • Consistent sleep schedule optimizes these natural cycles
        
        ⚡ Performance Effects:
        • 1-2 hours debt: Reduced alertness, mood changes
        • 3-4 hours debt: Impaired decision-making, slower reactions
        • 5+ hours debt: Significant cognitive impairment, health risks
        """
    }
}

struct SleepDebtInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let category = CalcBoxColors.CategoryColors.health
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "bed.double.fill")
                                .font(.title)
                                .foregroundColor(category.primary)
                                .frame(width: 40, height: 40)
                                .background(category.light)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sleep Debt Calculator")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(CalcBoxColors.Text.primary)
                                
                                Text("Understanding sleep deficit and recovery")
                                    .font(.subheadline)
                                    .foregroundColor(CalcBoxColors.Text.secondary)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        InfoSection(
                            title: "What is Sleep Debt?",
                            content: """
                            Sleep debt is the accumulated difference between the sleep you need and the sleep you actually get. Unlike other types of debt, you can't simply "pay it back" hour-for-hour - recovery requires extra time and consistent sleep habits.
                            
                            Research shows that sleep debt has compound effects on cognitive performance, immune function, and overall health.
                            """,
                            accentColor: category.primary
                        )
                        
                        InfoSection(
                            title: "How It's Calculated",
                            content: """
                            📊 Daily Deficit = Target Sleep - Actual Sleep
                            📈 Total Debt = Daily Deficit × Days Tracked
                            ⏰ Recovery Time = Total Debt × 1.5 × Chronotype Factor
                            📉 Performance Impact = Min(50%, Debt Hours × 10%)
                            
                            Weekend catch-up sleep is factored in but doesn't fully eliminate weekday deficits.
                            """,
                            accentColor: .blue
                        )
                        
                        InfoSection(
                            title: "Chronotype Impact",
                            content: """
                            🌅 Early Bird: Recover 10% faster from sleep debt
                            😴 Average: Standard recovery rate (baseline)
                            🦉 Night Owl: Recover 10% slower, need more consistency
                            
                            Your natural sleep preference affects how efficiently you can recover from sleep deficits.
                            """,
                            accentColor: .purple
                        )
                        
                        InfoSection(
                            title: "Health Implications",
                            content: """
                            🧠 Cognitive: Memory consolidation, decision-making, focus
                            💪 Physical: Immune function, muscle recovery, metabolism
                            😊 Mental: Mood regulation, stress response, emotional stability
                            🏃 Performance: Reaction time, coordination, productivity
                            
                            Even small amounts of sleep debt can have measurable effects on daily performance.
                            """,
                            accentColor: .green
                        )
                        
                        InfoSection(
                            title: "Recovery Strategies",
                            content: """
                            ✅ Consistent bedtime and wake time (even weekends)
                            ✅ Gradually increase sleep duration (15-30 min/night)
                            ✅ Optimize sleep environment (cool, dark, quiet)
                            ✅ Strategic napping (20-30 minutes, before 3 PM)
                            
                            ❌ Avoid trying to "catch up" with excessive weekend sleep
                            ❌ Don't rely on caffeine to mask sleep deprivation
                            """,
                            accentColor: category.accent
                        )
                    }
                }
                .padding(20)
            }
            .background(CalcBoxColors.Gradients.categoryBackground(category).ignoresSafeArea())
            .navigationTitle("Sleep Debt Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(category.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SleepDebtCalculatorView()
    }
}