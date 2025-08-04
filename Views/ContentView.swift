import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategory: CalculatorCategory? = nil
    
    var filteredCalculators: [Calculator] {
        let calculators = Calculator.allCalculators
        
        return calculators.filter { calculator in
            let matchesSearch = searchText.isEmpty || 
                calculator.name.localizedCaseInsensitiveContains(searchText) ||
                calculator.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || calculator.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var groupedCalculators: [CalculatorCategory: [Calculator]] {
        Dictionary(grouping: filteredCalculators) { $0.category }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                color: CalcBoxColors.CategoryColors.financial.primary
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = nil
                                }
                            }
                            
                            ForEach(CalculatorCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: category.colorScheme.primary,
                                    gradient: category.gradient
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Calculator List
                    if filteredCalculators.isEmpty {
                        EmptyStateView(searchText: searchText)
                            .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(CalculatorCategory.allCases, id: \.self) { category in
                                if let calculators = groupedCalculators[category], !calculators.isEmpty {
                                    CalculatorSection(
                                        category: category,
                                        calculators: calculators
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background {
                // Modern gradient background
                CalcBoxColors.Backgrounds.meshLight
                    .ignoresSafeArea()
            }
            .navigationTitle("CalcBox")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search calculators...")
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let gradient: LinearGradient?
    let action: () -> Void
    @State private var isPressed = false
    
    init(
        title: String,
        isSelected: Bool,
        color: Color,
        gradient: LinearGradient? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.gradient = gradient
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .foregroundColor(isSelected ? .white : CalcBoxColors.Text.primary)
                .background {
                    if isSelected {
                        if let gradient = gradient {
                            gradient
                        } else {
                            color
                        }
                    } else {
                        CalcBoxColors.Surface.elevated
                            .overlay(
                                color.opacity(0.1)
                            )
                    }
                }
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : color.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: isSelected ? color.opacity(0.3) : Color.clear,
                    radius: isSelected ? 6 : 0,
                    x: 0,
                    y: 2
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0.0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }
}

struct CalculatorSection: View {
    let category: CalculatorCategory
    let calculators: [Calculator]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                Text(category.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 4)
            
            // Calculator Cards
            ForEach(calculators) { calculator in
                NavigationLink(destination: calculator.destination) {
                    CalculatorCard(calculator: calculator)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CalculatorCard: View {
    let calculator: Calculator
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: calculator.icon)
                .font(.title2)
                .foregroundColor(calculator.category.color)
                .frame(width: 50, height: 50)
                .background(calculator.category.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(calculator.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(calculator.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EmptyStateView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No calculators found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try searching for something else")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}