import SwiftUI

struct NetWorthView: View {
    @State private var assets: [AssetItem] = [AssetItem()]
    @State private var liabilities: [LiabilityItem] = [LiabilityItem()]
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: NetWorthField?
    @State private var keyboardHeight: CGFloat = 0
    
    enum NetWorthField: Hashable, CaseIterable {
        case assetName(UUID)
        case assetValue(UUID)
        case liabilityName(UUID)
        case liabilityValue(UUID)
        
        static var allCases: [NetWorthField] { [] } // Dynamic fields, no static cases
    }
    
    struct AssetItem: Identifiable {
        let id = UUID()
        var name = ""
        var value = ""
        var category = AssetCategory.cash
    }
    
    struct LiabilityItem: Identifiable {
        let id = UUID()
        var name = ""
        var value = ""
        var category = LiabilityCategory.debt
    }
    
    enum AssetCategory: String, CaseIterable {
        case cash = "Cash & Savings"
        case investments = "Investments"
        case realEstate = "Real Estate"
        case retirement = "Retirement Accounts"
        case personal = "Personal Property"
        case other = "Other Assets"
    }
    
    enum LiabilityCategory: String, CaseIterable {
        case debt = "Credit Card Debt"
        case mortgage = "Mortgage"
        case studentLoan = "Student Loans"
        case autoLoan = "Auto Loans"
        case other = "Other Debts"
    }
    
    var totalAssets: Double {
        assets.compactMap { Double($0.value) }.reduce(0, +)
    }
    
    var totalLiabilities: Double {
        liabilities.compactMap { Double($0.value) }.reduce(0, +)
    }
    
    var netWorth: Double {
        totalAssets - totalLiabilities
    }
    
    var assetsByCategory: [(category: AssetCategory, total: Double)] {
        AssetCategory.allCases.map { category in
            let total = assets.filter { $0.category == category && !$0.value.isEmpty }
                           .compactMap { Double($0.value) }
                           .reduce(0, +)
            return (category, total)
        }.filter { $0.total > 0 }
    }
    
    var liabilitiesByCategory: [(category: LiabilityCategory, total: Double)] {
        LiabilityCategory.allCases.map { category in
            let total = liabilities.filter { $0.category == category && !$0.value.isEmpty }
                                  .compactMap { Double($0.value) }
                                  .reduce(0, +)
            return (category, total)
        }.filter { $0.total > 0 }
    }
    
    var netWorthRating: (rating: String, color: Color, description: String) {
        switch netWorth {
        case ..<0:
            return ("Needs Improvement", .red, "Focus on debt reduction and building assets")
        case 0..<10000:
            return ("Getting Started", .orange, "You're on the right track, keep building")
        case 10000..<50000:
            return ("Building Wealth", .yellow, "Good progress toward financial security")
        case 50000..<100000:
            return ("Strong Position", .blue, "You're building significant wealth")
        case 100000..<500000:
            return ("Excellent", .green, "Strong financial foundation")
        default:
            return ("Outstanding", .purple, "Exceptional wealth accumulation")
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Net Worth", description: "Track assets and liabilities") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() },
                        showShare: showResults
                    )
                // Assets Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Assets")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                        Button("Add Asset") {
                            assets.append(AssetItem())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(assets.indices, id: \.self) { index in
                        AssetRowView(
                            asset: $assets[index],
                            onDelete: {
                                if assets.count > 1 {
                                    assets.remove(at: index)
                                }
                            },
                            focusedField: $focusedField,
                            onNext: { field in focusNextField(field) },
                            onPrevious: { field in focusPreviousField(field) }
                        )
                    }
                }
                
                Divider()
                
                // Liabilities Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Liabilities")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                        Button("Add Liability") {
                            liabilities.append(LiabilityItem())
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }
                    
                    ForEach(liabilities.indices, id: \.self) { index in
                        LiabilityRowView(
                            liability: $liabilities[index],
                            onDelete: {
                                if liabilities.count > 1 {
                                    liabilities.remove(at: index)
                                }
                            },
                            focusedField: $focusedField,
                            onNext: { field in focusNextField(field) },
                            onPrevious: { field in focusPreviousField(field) }
                        )
                    }
                }
                
                    // Calculate Button
                    CalculatorButton(title: "Calculate Net Worth") {
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
                            
                            Text("Net Worth Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Net Worth Result
                        CalculatorResultCard(
                            title: "Net Worth",
                            value: NumberFormatter.formatCurrency(netWorth),
                            subtitle: netWorthRating.rating,
                            color: netWorthRating.color
                        )
                        
                        // Rating Description
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(netWorthRating.color)
                            Text(netWorthRating.description)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(netWorthRating.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Summary
                        HStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "Total Assets",
                                value: NumberFormatter.formatCurrency(totalAssets),
                                color: .green
                            )
                            
                            CalculatorResultCard(
                                title: "Total Liabilities",
                                value: NumberFormatter.formatCurrency(totalLiabilities),
                                color: .red
                            )
                        }
                        
                        // Asset Breakdown
                        if !assetsByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Assets by Category")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    ForEach(assetsByCategory, id: \.category) { item in
                                        InfoRow(
                                            label: item.category.rawValue,
                                            value: NumberFormatter.formatCurrency(item.total)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGreen).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Liability Breakdown
                        if !liabilitiesByCategory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Liabilities by Category")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 8) {
                                    ForEach(liabilitiesByCategory, id: \.category) { item in
                                        InfoRow(
                                            label: item.category.rawValue,
                                            value: NumberFormatter.formatCurrency(item.total)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemRed).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Tips for Improvement
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Tips to Improve Net Worth")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if netWorth < 0 {
                                    Text("• Focus on paying down high-interest debt first")
                                        .fontWeight(.medium)
                                }
                                Text("• Build an emergency fund (3-6 months expenses)")
                                Text("• Maximize employer 401(k) matching")
                                Text("• Consider low-cost index fund investments")
                                Text("• Track your net worth monthly to monitor progress")
                                Text("• Avoid lifestyle inflation as income increases")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemYellow).opacity(0.1))
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
            NetWorthInfoSheet()
        }
    }
    
    private func fillDemoDataAndCalculate() {
        assets = [
            AssetItem(name: "Checking Account", value: "5000", category: .cash),
            AssetItem(name: "Savings Account", value: "25000", category: .cash),
            AssetItem(name: "401(k)", value: "75000", category: .retirement),
            AssetItem(name: "Home", value: "300000", category: .realEstate),
            AssetItem(name: "Car", value: "20000", category: .personal)
        ]
        
        liabilities = [
            LiabilityItem(name: "Mortgage", value: "250000", category: .mortgage),
            LiabilityItem(name: "Credit Card", value: "3000", category: .debt),
            LiabilityItem(name: "Car Loan", value: "15000", category: .autoLoan)
        ]
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        assets = [AssetItem()]
        liabilities = [LiabilityItem()]
        
        withAnimation {
            showResults = false
        }
    }
    
    private func focusNextField(_ currentField: NetWorthField) {
        // Get current asset and liability indices for navigation
        var allFields: [NetWorthField] = []
        
        // Add all asset fields
        for asset in assets {
            allFields.append(NetWorthField.assetName(asset.id))
            allFields.append(NetWorthField.assetValue(asset.id))
        }
        
        // Add all liability fields
        for liability in liabilities {
            allFields.append(NetWorthField.liabilityName(liability.id))
            allFields.append(NetWorthField.liabilityValue(liability.id))
        }
        
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let nextIndex = currentIndex + 1
            if nextIndex < allFields.count {
                focusedField = allFields[nextIndex]
            } else {
                focusedField = nil
            }
        }
    }
    
    private func focusPreviousField(_ currentField: NetWorthField) {
        // Get current asset and liability indices for navigation
        var allFields: [NetWorthField] = []
        
        // Add all asset fields
        for asset in assets {
            allFields.append(NetWorthField.assetName(asset.id))
            allFields.append(NetWorthField.assetValue(asset.id))
        }
        
        // Add all liability fields
        for liability in liabilities {
            allFields.append(NetWorthField.liabilityName(liability.id))
            allFields.append(NetWorthField.liabilityValue(liability.id))
        }
        
        if let currentIndex = allFields.firstIndex(of: currentField) {
            let previousIndex = currentIndex - 1
            if previousIndex >= 0 {
                focusedField = allFields[previousIndex]
            }
        }
    }
    
    private func shareResults() {
        let shareText = """
        Net Worth Summary:
        Total Assets: \(NumberFormatter.formatCurrency(totalAssets))
        Total Liabilities: \(NumberFormatter.formatCurrency(totalLiabilities))
        Net Worth: \(NumberFormatter.formatCurrency(netWorth))
        Rating: \(netWorthRating.rating)
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

struct NetWorthInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Net Worth Calculator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it calculates",
                            content: "Your net worth is the difference between your total assets and total liabilities. It's a key measure of your financial health."
                        )
                        
                        InfoSection(
                            title: "Assets",
                            content: """
                            • Cash & Savings: Bank accounts, CDs
                            • Investments: Stocks, bonds, mutual funds
                            • Real Estate: Home value, rental properties
                            • Retirement: 401(k), IRA, pension values
                            • Personal Property: Cars, jewelry, collectibles
                            """
                        )
                        
                        InfoSection(
                            title: "Liabilities",
                            content: """
                            • Mortgages: Home loans, HELOC
                            • Credit Cards: Outstanding balances
                            • Loans: Auto, student, personal loans
                            • Other Debts: Medical bills, back taxes
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Net Worth Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct AssetRowView: View {
    @Binding var asset: NetWorthView.AssetItem
    let onDelete: () -> Void
    var focusedField: FocusState<NetWorthView.NetWorthField?>.Binding
    var onNext: ((NetWorthView.NetWorthField) -> Void)?
    var onPrevious: ((NetWorthView.NetWorthField) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                CompactInputField(
                    title: "Asset Name",
                    value: $asset.name,
                    placeholder: "e.g., Checking Account",
                    color: .green,
                    keyboardType: .default,
                    onPrevious: { onPrevious?(NetWorthView.NetWorthField.assetName(asset.id)) },
                    onNext: { onNext?(NetWorthView.NetWorthField.assetName(asset.id)) },
                    onDone: { focusedField.wrappedValue = nil }
                )
                .focused(focusedField, equals: NetWorthView.NetWorthField.assetName(asset.id))
                .id(NetWorthView.NetWorthField.assetName(asset.id))
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Picker("Category", selection: $asset.category) {
                        ForEach(NetWorthView.AssetCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                CompactInputField(
                    title: "Value",
                    value: $asset.value,
                    placeholder: "0",
                    prefix: "$",
                    color: .green,
                    keyboardType: .decimalPad,
                    onPrevious: { onPrevious?(NetWorthView.NetWorthField.assetValue(asset.id)) },
                    onNext: { onNext?(NetWorthView.NetWorthField.assetValue(asset.id)) },
                    onDone: { focusedField.wrappedValue = nil }
                )
                .focused(focusedField, equals: NetWorthView.NetWorthField.assetValue(asset.id))
                .id(NetWorthView.NetWorthField.assetValue(asset.id))
                .frame(width: 120)
            }
        }
        .padding()
        .background(Color(.systemGreen).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LiabilityRowView: View {
    @Binding var liability: NetWorthView.LiabilityItem
    let onDelete: () -> Void
    var focusedField: FocusState<NetWorthView.NetWorthField?>.Binding
    var onNext: ((NetWorthView.NetWorthField) -> Void)?
    var onPrevious: ((NetWorthView.NetWorthField) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                CompactInputField(
                    title: "Liability Name",
                    value: $liability.name,
                    placeholder: "e.g., Credit Card",
                    color: .red,
                    keyboardType: .default,
                    onPrevious: { onPrevious?(NetWorthView.NetWorthField.liabilityName(liability.id)) },
                    onNext: { onNext?(NetWorthView.NetWorthField.liabilityName(liability.id)) },
                    onDone: { focusedField.wrappedValue = nil }
                )
                .focused(focusedField, equals: NetWorthView.NetWorthField.liabilityName(liability.id))
                .id(NetWorthView.NetWorthField.liabilityName(liability.id))
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Picker("Category", selection: $liability.category) {
                        ForEach(NetWorthView.LiabilityCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                
                CompactInputField(
                    title: "Amount Owed",
                    value: $liability.value,
                    placeholder: "0",
                    prefix: "$",
                    color: .red,
                    keyboardType: .decimalPad,
                    onPrevious: { onPrevious?(NetWorthView.NetWorthField.liabilityValue(liability.id)) },
                    onNext: { onNext?(NetWorthView.NetWorthField.liabilityValue(liability.id)) },
                    onDone: { focusedField.wrappedValue = nil }
                )
                .focused(focusedField, equals: NetWorthView.NetWorthField.liabilityValue(liability.id))
                .id(NetWorthView.NetWorthField.liabilityValue(liability.id))
                .frame(width: 120)
            }
        }
        .padding()
        .background(Color(.systemRed).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}