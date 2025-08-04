import SwiftUI

struct PregnancyCalculatorView: View {
    @State private var lastPeriodDate = Date()
    @State private var cycleLength = "28"
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: PregnancyField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum PregnancyField: CaseIterable {
        case cycleLength
    }
    
    var estimatedDueDate: Date {
        // Add 280 days (40 weeks) to last menstrual period
        Calendar.current.date(byAdding: .day, value: 280, to: lastPeriodDate) ?? Date()
    }
    
    var conceptionDate: Date {
        // Typically 14 days after last period (for 28-day cycle)
        let ovulationDay = (Double(cycleLength) ?? 28) / 2
        return Calendar.current.date(byAdding: .day, value: Int(ovulationDay), to: lastPeriodDate) ?? Date()
    }
    
    var currentWeek: Int {
        let daysSinceLastPeriod = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        return daysSinceLastPeriod / 7
    }
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: estimatedDueDate).day ?? 0
    }
    
    var trimester: (number: Int, description: String) {
        let week = currentWeek
        if week <= 12 {
            return (1, "First Trimester - Development of major organs")
        } else if week <= 27 {
            return (2, "Second Trimester - Often called the 'golden period'")
        } else {
            return (3, "Third Trimester - Final growth and preparation for birth")
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Pregnancy Due Date", description: "Calculate estimated due date") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                    
                    // Last Period Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Day of Last Menstrual Period")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "Last Period Date",
                            selection: $lastPeriodDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Cycle Length
                    ModernInputField(
                        title: "Average Cycle Length",
                        value: $cycleLength,
                        placeholder: "28",
                        suffix: "days",
                        icon: "calendar.circle.fill",
                        color: .pink,
                        keyboardType: .numberPad,
                        helpText: "Typical cycle length (usually 21-35 days)",
                        onNext: { focusedField = nil },
                        onDone: { focusedField = nil },
                        showPreviousButton: false,
                        showNextButton: false
                    )
                    .focused($focusedField, equals: .cycleLength)
                    .id(PregnancyField.cycleLength)
                
                // Calculate Button
                CalculatorButton(title: "Calculate Due Date") {
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
                if showResults {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("Pregnancy Timeline")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Due Date
                        CalculatorResultCard(
                            title: "Estimated Due Date",
                            value: DateFormatter.longDateFormatter.string(from: estimatedDueDate),
                            subtitle: DateFormatter.relativeDateFormatter.localizedString(for: estimatedDueDate, relativeTo: Date()),
                            color: .pink
                        )
                        
                        // Current Status
                        if daysRemaining > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Current Status")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    InfoRow(
                                        label: "Weeks pregnant",
                                        value: "\(currentWeek) weeks"
                                    )
                                    InfoRow(
                                        label: "Current trimester",
                                        value: "\(trimester.number)"
                                    )
                                    InfoRow(
                                        label: "Days until due date",
                                        value: "\(daysRemaining) days"
                                    )
                                    InfoRow(
                                        label: "Weeks remaining",
                                        value: "\(daysRemaining / 7) weeks"
                                    )
                                }
                                
                                Text(trimester.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color(.systemPink).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Important Dates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Important Dates")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Last menstrual period",
                                    value: DateFormatter.mediumDateFormatter.string(from: lastPeriodDate)
                                )
                                InfoRow(
                                    label: "Estimated conception",
                                    value: DateFormatter.mediumDateFormatter.string(from: conceptionDate)
                                )
                                InfoRow(
                                    label: "End of 1st trimester",
                                    value: DateFormatter.mediumDateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 84, to: lastPeriodDate) ?? Date())
                                )
                                InfoRow(
                                    label: "End of 2nd trimester",
                                    value: DateFormatter.mediumDateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 189, to: lastPeriodDate) ?? Date())
                                )
                                InfoRow(
                                    label: "Due date",
                                    value: DateFormatter.mediumDateFormatter.string(from: estimatedDueDate)
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Milestone Schedule
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Typical Milestones by Week")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let milestones = [
                                ("Week 8", "First prenatal appointment"),
                                ("Week 12", "End of first trimester, nuchal translucency scan"),
                                ("Week 16", "Possible gender determination"),
                                ("Week 20", "Anatomy scan, halfway point"),
                                ("Week 24", "Glucose screening test"),
                                ("Week 28", "Start of third trimester"),
                                ("Week 36", "Baby considered full-term soon"),
                                ("Week 40", "Due date - baby is full-term")
                            ]
                            
                            VStack(spacing: 6) {
                                ForEach(milestones, id: \.0) { milestone in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(milestone.0)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                        }
                                        Text(milestone.1)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Important Note
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Important Information")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• This is an estimation based on a 280-day pregnancy")
                                Text("• Only about 5% of babies are born on their due date")
                                Text("• Full-term is considered 37-42 weeks")
                                Text("• Consult healthcare providers for personalized care")
                                Text("• Due dates may be adjusted after ultrasound scans")
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
            PregnancyInfoSheet()
        }
    }
    
    private func fillDemoDataAndCalculate() {
        // Set to 8 weeks ago for demo
        lastPeriodDate = Calendar.current.date(byAdding: .day, value: -56, to: Date()) ?? Date()
        cycleLength = "28"
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        lastPeriodDate = Date()
        cycleLength = "28"
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Pregnancy Due Date Calculation:
        Last Period: \(DateFormatter.mediumDateFormatter.string(from: lastPeriodDate))
        Estimated Due Date: \(DateFormatter.longDateFormatter.string(from: estimatedDueDate))
        Current Week: \(currentWeek) weeks pregnant
        Days Remaining: \(daysRemaining) days
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

struct PregnancyInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Pregnancy Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator estimates your due date based on the first day of your last menstrual period using the standard 280-day (40-week) pregnancy calculation."
                        )
                        
                        InfoSection(
                            title: "How it works",
                            content: """
                            • Adds 280 days (40 weeks) to your last period
                            • Estimates conception around ovulation (cycle midpoint)
                            • Calculates current week and trimester
                            • Provides important milestone dates
                            """
                        )
                        
                        InfoSection(
                            title: "Trimester breakdown",
                            content: """
                            • First Trimester: Weeks 1-12 (organ development)
                            • Second Trimester: Weeks 13-27 ('golden period')
                            • Third Trimester: Weeks 28-40 (final growth)
                            """
                        )
                        
                        InfoSection(
                            title: "Important notes",
                            content: """
                            • Only 5% of babies are born on their due date
                            • Full-term is 37-42 weeks
                            • Ultrasounds may adjust due dates
                            • Always consult healthcare providers
                            • This is an estimate, not medical advice
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Pregnancy Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}