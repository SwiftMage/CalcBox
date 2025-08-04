import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategory: CalculatorCategory? = nil
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @Environment(\.colorScheme) var colorScheme
    #if DEBUG
    @ObservedObject private var ratingManager = RatingRequestManager.shared
    #endif
    
    var filteredCalculators: [Calculator] {
        let calculators: [Calculator]
        
        // Handle favorites category specially
        if selectedCategory == .favorites {
            calculators = favoritesManager.getFavoriteCalculators()
        } else {
            calculators = Calculator.allCalculators
        }
        
        return calculators.filter { calculator in
            let matchesSearch = searchText.isEmpty || 
                calculator.name.localizedCaseInsensitiveContains(searchText) ||
                calculator.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || 
                                selectedCategory == .favorites || 
                                calculator.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var groupedCalculators: [CalculatorCategory: [Calculator]] {
        if selectedCategory == .favorites {
            return [.favorites: filteredCalculators]
        } else {
            return Dictionary(grouping: filteredCalculators) { $0.category }
        }
    }
    
    var displayCategories: [CalculatorCategory] {
        if selectedCategory == .favorites {
            return [.favorites]
        } else if selectedCategory == nil {
            return CalculatorCategory.allCases.filter { category in
                if category == .favorites {
                    return favoritesManager.hasFavorites
                } else {
                    return groupedCalculators[category]?.isEmpty == false
                }
            }
        } else {
            return CalculatorCategory.allCases.filter { category in
                groupedCalculators[category]?.isEmpty == false
            }
        }
    }
    
    @ViewBuilder
    private var categoryFilterSection: some View {
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
                    // Only show Favorites chip if there are favorites
                    if category != .favorites || favoritesManager.hasFavorites {
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
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var calculatorListSection: some View {
        if filteredCalculators.isEmpty {
            EmptyStateView(searchText: searchText)
                .padding(.top, 50)
        } else {
            LazyVStack(spacing: 20) {
                ForEach(displayCategories, id: \.self) { category in
                    if let calculators = groupedCalculators[category], !calculators.isEmpty {
                        CalculatorSection(
                            category: category,
                            calculators: calculators,
                            favoritesManager: favoritesManager
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var backgroundGradient: some View {
        if colorScheme == .dark {
            // Dark mode gradient with better contrast
            LinearGradient(
                colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.systemBackground).opacity(0.95),
                    Color(UIColor.secondarySystemBackground).opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        } else {
            // Light mode gradient
            CalcBoxColors.Backgrounds.meshLight
                .ignoresSafeArea()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    categoryFilterSection
                    calculatorListSection
                }
                .padding(.vertical, 20)
            }
            .background(backgroundGradient)
            .navigationTitle("CalcBox")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search calculators...")
            .onChange(of: favoritesManager.favoriteCalculatorNames) { _ in
                // If viewing favorites but no favorites exist, switch to "All"
                if selectedCategory == .favorites && !favoritesManager.hasFavorites {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedCategory = nil
                    }
                }
            }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Test Rating Request") {
                            RatingRequestManager.shared.requestRatingManually()
                        }
                        Button("Reset Rating Count") {
                            RatingRequestManager.shared.resetForTesting()
                        }
                        Divider()
                        Button("Clear All Favorites") {
                            favoritesManager.clearAllFavorites()
                        }
                        Text("Press Count: \(ratingManager.buttonPressCount)")
                        Text("Favorites: \(favoritesManager.favoriteCalculatorNames.count)")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            #endif
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
    let favoritesManager: FavoritesManager
    
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
                    CalculatorCard(calculator: calculator, favoritesManager: favoritesManager)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 4) // Add spacing between rows
            }
        }
    }
}

struct CalculatorCard: View {
    let calculator: Calculator
    @ObservedObject var favoritesManager: FavoritesManager
    @State private var isStarPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: calculator.icon)
                .font(.title2)
                .foregroundColor(calculator.category.color)
                .frame(width: 50, height: 50)
                .background(calculator.category.color.opacity(colorScheme == .dark ? 0.15 : 0.1))
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
            
            // Star Button
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                favoritesManager.toggleFavorite(calculator)
            }) {
                Image(systemName: favoritesManager.isFavorite(calculator) ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(favoritesManager.isFavorite(calculator) ? Color(hex: "FFD700") : .secondary)
                    .scaleEffect(isStarPressed ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isStarPressed)
                    .animation(.easeInOut(duration: 0.2), value: favoritesManager.isFavorite(calculator))
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(
                minimumDuration: 0.0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isStarPressed = pressing
                },
                perform: {}
            )
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background {
            if colorScheme == .dark {
                // Enhanced dark mode styling with better contrast
                CalcBoxColors.Surface.elevated
                    .overlay(
                        // Subtle gradient overlay for depth
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.02),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                // Light mode styling
                CalcBoxColors.Surface.card
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            // Subtle border for better definition in dark mode
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark ? 
                        Color.white.opacity(0.1) : 
                        Color.clear,
                    lineWidth: 0.5
                )
        )
        .shadow(
            color: colorScheme == .dark ? 
                Color.black.opacity(0.3) : 
                Color.black.opacity(0.05),
            radius: colorScheme == .dark ? 6 : 8,
            x: 0,
            y: colorScheme == .dark ? 3 : 2
        )
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