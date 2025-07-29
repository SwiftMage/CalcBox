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
                VStack(spacing: 20) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                color: .gray
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = nil
                                }
                            }
                            
                            ForEach(CalculatorCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Calculator List
                    if filteredCalculators.isEmpty {
                        EmptyStateView(searchText: searchText)
                            .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(CalculatorCategory.allCases, id: \.self) { category in
                                if let calculators = groupedCalculators[category], !calculators.isEmpty {
                                    CalculatorSection(
                                        category: category,
                                        calculators: calculators
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("CalcBox")
            .searchable(text: $searchText, prompt: "Search calculators")
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
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