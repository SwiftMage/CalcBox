import SwiftUI

struct GPACalculatorView: View {
    @State private var courses: [Course] = [Course()]
    @State private var gpaScale = GPAScale.fourPoint
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: GPAField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum GPAField: CaseIterable, Hashable {
        case courseName(Int)
        case creditHours(Int)
        
        static var allCases: [GPAField] {
            return [.courseName(0), .creditHours(0)]
        }
    }
    
    enum GPAScale: String, CaseIterable {
        case fourPoint = "4.0 Scale"
        case fivePoint = "5.0 Scale (Weighted)"
        
        var maxValue: Double {
            switch self {
            case .fourPoint: return 4.0
            case .fivePoint: return 5.0
            }
        }
    }
    
    struct Course: Identifiable {
        let id = UUID()
        var name = ""
        var grade = Grade.a
        var creditHours = "3"
        var isHonorsAP = false
    }
    
    enum Grade: String, CaseIterable {
        case aPlus = "A+"
        case a = "A"
        case aMinus = "A-"
        case bPlus = "B+"
        case b = "B"
        case bMinus = "B-"
        case cPlus = "C+"
        case c = "C"
        case cMinus = "C-"
        case dPlus = "D+"
        case d = "D"
        case f = "F"
        
        func gpaValue(scale: GPAScale, isHonorsAP: Bool = false) -> Double {
            let baseValue: Double
            switch self {
            case .aPlus, .a: baseValue = 4.0
            case .aMinus: baseValue = 3.7
            case .bPlus: baseValue = 3.3
            case .b: baseValue = 3.0
            case .bMinus: baseValue = 2.7
            case .cPlus: baseValue = 2.3
            case .c: baseValue = 2.0
            case .cMinus: baseValue = 1.7
            case .dPlus: baseValue = 1.3
            case .d: baseValue = 1.0
            case .f: baseValue = 0.0
            }
            
            if scale == .fivePoint && isHonorsAP && baseValue > 0 {
                return min(baseValue + 1.0, 5.0)
            }
            
            return baseValue
        }
    }
    
    var calculatedGPA: Double {
        let validCourses = courses.filter { !$0.name.isEmpty }
        guard !validCourses.isEmpty else { return 0 }
        
        var totalPoints = 0.0
        var totalCredits = 0.0
        
        for course in validCourses {
            guard let credits = Double(course.creditHours), credits > 0 else { continue }
            let gradePoints = course.grade.gpaValue(scale: gpaScale, isHonorsAP: course.isHonorsAP)
            totalPoints += gradePoints * credits
            totalCredits += credits
        }
        
        return totalCredits > 0 ? totalPoints / totalCredits : 0
    }
    
    var totalCreditHours: Double {
        courses.compactMap { Double($0.creditHours) }.reduce(0, +)
    }
    
    var gpaCategory: (category: String, color: Color, description: String) {
        switch calculatedGPA {
        case 3.8...4.0:
            return ("Summa Cum Laude", .green, "Highest Honors - Excellent academic performance")
        case 3.5..<3.8:
            return ("Magna Cum Laude", .blue, "High Honors - Very good academic performance")
        case 3.2..<3.5:
            return ("Cum Laude", .purple, "Honors - Good academic performance")
        case 3.0..<3.2:
            return ("Good Standing", .orange, "Satisfactory academic performance")
        case 2.0..<3.0:
            return ("Academic Warning", .yellow, "Below average - improvement needed")
        default:
            return ("Academic Probation", .red, "Unsatisfactory - immediate improvement required")
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "GPA Calculator", description: "Calculate grade point average") {
                VStack(spacing: 24) {
                // Quick Action Buttons
                QuickActionButtonRow(
                    onExample: { fillDemoDataAndCalculate() },
                    onClear: { clearAllData() },
                    onInfo: { showInfo = true },
                    onShare: { shareResults() },
                    showShare: showResults
                )
                
                // GPA Scale Selection
                GroupedInputFields(
                    title: "GPA Settings",
                    icon: "graduationcap.fill",
                    color: .blue
                ) {
                    SegmentedPicker(
                        title: "GPA Scale",
                        selection: $gpaScale,
                        options: GPAScale.allCases.map { ($0, $0.rawValue) }
                    )
                }
                
                // Courses Section
                GroupedInputFields(
                    title: "Courses",
                    icon: "book.fill",
                    color: .green
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Course List")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button("Add Course") {
                                courses.append(Course())
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                        
                        ForEach(courses.indices, id: \.self) { index in
                            CourseRowView(
                                course: $courses[index],
                                gpaScale: gpaScale,
                                courseIndex: index,
                                focusedField: $focusedField,
                                onDelete: {
                                    if courses.count > 1 {
                                        courses.remove(at: index)
                                    }
                                },
                                onNext: { focusNextField(.courseName(index)) },
                                onPrevious: { focusPreviousField(.courseName(index)) }
                            )
                            .id("course_\(index)")
                        }
                    }
                }
                
                // Calculate Button
                CalculatorButton(title: "Calculate GPA") {
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
                if showResults && calculatedGPA > 0 {
                    VStack(spacing: 16) {
                        Divider()
                            .id("results")
                        
                        Text("GPA Results")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main GPA Result
                        CalculatorResultCard(
                            title: "Your GPA",
                            value: String(format: "%.2f", calculatedGPA),
                            subtitle: "\(gpaScale.rawValue) (\(gpaCategory.category))",
                            color: gpaCategory.color
                        )
                        
                        // GPA Category Description
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(gpaCategory.color)
                            Text(gpaCategory.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(gpaCategory.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Academic Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Academic Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                InfoRow(
                                    label: "Total Credit Hours",
                                    value: String(format: "%.0f", totalCreditHours)
                                )
                                InfoRow(
                                    label: "Number of Courses",
                                    value: "\(courses.filter { !$0.name.isEmpty }.count)"
                                )
                                InfoRow(
                                    label: "GPA Scale",
                                    value: gpaScale.rawValue
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Grade Distribution
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Grade Distribution")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let gradeDistribution = Dictionary(grouping: courses.filter { !$0.name.isEmpty }) { $0.grade }
                            
                            VStack(spacing: 6) {
                                ForEach(Grade.allCases, id: \.self) { grade in
                                    if let coursesWithGrade = gradeDistribution[grade], !coursesWithGrade.isEmpty {
                                        InfoRow(
                                            label: grade.rawValue,
                                            value: "\(coursesWithGrade.count) course\(coursesWithGrade.count > 1 ? "s" : "")"
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
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
                        switch field {
                        case .courseName(let index), .creditHours(let index):
                            proxy.scrollTo("course_\(index)", anchor: .center)
                        }
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
            GPAInfoSheet()
        }
    }
    
    private func focusNextField(_ currentField: GPAField) {
        switch currentField {
        case .courseName(let index):
            focusedField = .creditHours(index)
        case .creditHours(let index):
            if index < courses.count - 1 {
                focusedField = .courseName(index + 1)
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: GPAField) {
        switch currentField {
        case .courseName(let index):
            if index > 0 {
                focusedField = .creditHours(index - 1)
            }
        case .creditHours(let index):
            focusedField = .courseName(index)
        }
    }
    
    private func fillDemoDataAndCalculate() {
        courses = [
            Course(name: "Calculus I", grade: .a, creditHours: "4", isHonorsAP: false),
            Course(name: "English Composition", grade: .aMinus, creditHours: "3", isHonorsAP: false),
            Course(name: "Biology", grade: .bPlus, creditHours: "4", isHonorsAP: true),
            Course(name: "History", grade: .b, creditHours: "3", isHonorsAP: false),
            Course(name: "Chemistry", grade: .aMinus, creditHours: "4", isHonorsAP: true)
        ]
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        courses = [Course()]
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let courseList = courses.filter { !$0.name.isEmpty }
            .map { "\($0.name): \($0.grade.rawValue) (\($0.creditHours) credits)" }
            .joined(separator: "\n")
        
        let shareText = """
        GPA Calculation Results:
        GPA: \(String(format: "%.2f", calculatedGPA)) (\(gpaScale.rawValue))
        Category: \(gpaCategory.category)
        Total Credit Hours: \(String(format: "%.0f", totalCreditHours))
        
        Courses:
        \(courseList)
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

struct CourseRowView: View {
    @Binding var course: GPACalculatorView.Course
    let gpaScale: GPACalculatorView.GPAScale
    let courseIndex: Int
    @FocusState.Binding var focusedField: GPACalculatorView.GPAField?
    let onDelete: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ModernInputField(
                    title: "Course Name",
                    value: $course.name,
                    placeholder: "e.g., Calculus I",
                    icon: "book.fill",
                    color: .blue,
                    keyboardType: .default,
                    helpText: "Enter the course name",
                    onPrevious: courseIndex > 0 ? onPrevious : nil,
                    onNext: onNext,
                    onDone: { focusedField = nil },
                    showPreviousButton: courseIndex > 0
                )
                .focused($focusedField, equals: .courseName(courseIndex))
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grade")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Picker("Grade", selection: $course.grade) {
                        ForEach(GPACalculatorView.Grade.allCases, id: \.self) { grade in
                            Text(grade.rawValue).tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .tint(.blue)
                }
                
                CompactInputField(
                    title: "Credits",
                    value: $course.creditHours,
                    placeholder: "3",
                    color: .orange,
                    keyboardType: .numberPad,
                    onPrevious: onPrevious,
                    onNext: { focusedField = nil },
                    onDone: { focusedField = nil },
                    showNextButton: false
                )
                .focused($focusedField, equals: .creditHours(courseIndex))
                
                if gpaScale == .fivePoint {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Honors/AP")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Toggle("", isOn: $course.isHonorsAP)
                            .labelsHidden()
                            .tint(.purple)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GPAInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About GPA Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "This calculator computes your Grade Point Average (GPA) based on course grades and credit hours. It supports both 4.0 and 5.0 (weighted) scales."
                        )
                        
                        InfoSection(
                            title: "How GPA is calculated",
                            content: """
                            • Each grade has a point value (A=4.0, B=3.0, etc.)
                            • Multiply grade points by credit hours for each course
                            • Sum all grade points and divide by total credit hours
                            • Weighted (5.0) scale adds 1 point for Honors/AP courses
                            """
                        )
                        
                        InfoSection(
                            title: "Grade Scale",
                            content: """
                            • A+ / A = 4.0 points
                            • A- = 3.7 points
                            • B+ = 3.3 points
                            • B = 3.0 points
                            • B- = 2.7 points
                            • C+ = 2.3 points
                            • C = 2.0 points
                            • C- = 1.7 points
                            • D+ = 1.3 points
                            • D = 1.0 points
                            • F = 0.0 points
                            """
                        )
                        
                        InfoSection(
                            title: "Academic Standing",
                            content: """
                            • 3.8-4.0: Summa Cum Laude (Highest Honors)
                            • 3.5-3.7: Magna Cum Laude (High Honors)
                            • 3.2-3.4: Cum Laude (Honors)
                            • 3.0-3.1: Good Standing
                            • 2.0-2.9: Academic Warning
                            • Below 2.0: Academic Probation
                            """
                        )
                        
                        InfoSection(
                            title: "Tips for Success",
                            content: """
                            • Focus on high-credit courses for maximum impact
                            • Consider retaking low-grade courses if allowed
                            • Take advantage of Honors/AP courses on weighted scale
                            • Maintain consistent study habits across all courses
                            • Seek help early if struggling in any class
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("GPA Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}