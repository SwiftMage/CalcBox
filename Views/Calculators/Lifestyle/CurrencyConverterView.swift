import SwiftUI
import Combine

enum CurrencyField: CaseIterable {
    case amount
}

enum Currency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cad = "CAD"
    case aud = "AUD"
    case chf = "CHF"
    case cny = "CNY"
    case inr = "INR"
    case krw = "KRW"
    
    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .chf: return "Swiss Franc"
        case .cny: return "Chinese Yuan"
        case .inr: return "Indian Rupee"
        case .krw: return "South Korean Won"
        }
    }
    
    var symbol: String {
        switch self {
        case .usd, .cad, .aud: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy, .cny: return "¥"
        case .chf: return "CHF"
        case .inr: return "₹"
        case .krw: return "₩"
        }
    }
    
    // Approximate exchange rates (in real app, would fetch from API)
    var rateToUSD: Double {
        switch self {
        case .usd: return 1.0
        case .eur: return 1.08
        case .gbp: return 1.27
        case .jpy: return 0.0067
        case .cad: return 0.74
        case .aud: return 0.66
        case .chf: return 1.11
        case .cny: return 0.14
        case .inr: return 0.012
        case .krw: return 0.00076
        }
    }
}

struct CurrencyConverterView: View {
    @State private var amount = ""
    @State private var fromCurrency = Currency.usd
    @State private var toCurrency = Currency.eur
    @State private var showResults = false
    @State private var showInfo = false
    @FocusState private var focusedField: CurrencyField?
    @State private var keyboardHeight: CGFloat = 0
    
    var convertedAmount: Double {
        guard let inputAmount = Double(amount), inputAmount > 0 else { return 0 }
        
        // Convert to USD first, then to target currency
        let usdAmount = inputAmount * fromCurrency.rateToUSD
        return usdAmount / toCurrency.rateToUSD
    }
    
    var exchangeRate: Double {
        fromCurrency.rateToUSD / toCurrency.rateToUSD
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CalculatorView(title: "Currency Converter", description: "Convert between currencies") {
                VStack(spacing: 24) {
                    // Quick Action Buttons
                    QuickActionButtonRow(
                        onExample: { fillDemoDataAndCalculate() },
                        onClear: { clearAllData() },
                        onInfo: { showInfo = true },
                        onShare: { shareResults() }
                    )
                    
                    // Input Section
                    GroupedInputFields(title: "Amount", icon: "dollarsign.circle.fill", color: .blue) {
                        ModernInputField(
                            title: "Amount to Convert",
                            value: $amount,
                            placeholder: "0.00",
                            prefix: fromCurrency.symbol,
                            icon: "dollarsign.circle.fill",
                            keyboardType: .decimalPad,
                            helpText: "Enter the amount you want to convert",
                            onPrevious: nil,
                            onNext: nil,
                            onDone: { focusedField = nil },
                            showPreviousButton: false,
                            showNextButton: false
                        )
                        .focused($focusedField, equals: .amount)
                        .id(CurrencyField.amount)
                    }
                    
                    // Currency Selection
                    GroupedInputFields(title: "From Currency", icon: "arrow.up.circle.fill", color: .green) {
                        Picker("From Currency", selection: $fromCurrency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text("\(currency.symbol) \(currency.rawValue) - \(currency.name)").tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Swap Button
                    Button(action: {
                        withAnimation(.spring()) {
                            let temp = fromCurrency
                            fromCurrency = toCurrency
                            toCurrency = temp
                        }
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    GroupedInputFields(title: "To Currency", icon: "arrow.down.circle.fill", color: .orange) {
                        Picker("To Currency", selection: $toCurrency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Text("\(currency.symbol) \(currency.rawValue) - \(currency.name)").tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Convert Currency")
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
                    .disabled(amount.isEmpty)
                    
                    if showResults && !amount.isEmpty {
                        VStack(spacing: 16) {
                            CalculatorResultCard(
                                title: "\(fromCurrency.symbol)\(amount) \(fromCurrency.rawValue)",
                                value: "\(toCurrency.symbol)\(String(format: "%.2f", convertedAmount))",
                                subtitle: toCurrency.rawValue,
                                color: .green
                            )
                            .id("results")
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Exchange Rate")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                Text("1 \(fromCurrency.rawValue) = \(String(format: "%.4f", exchangeRate)) \(toCurrency.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Quick conversion examples
                                VStack(spacing: 8) {
                                    ForEach([1, 5, 10, 100], id: \.self) { quickAmount in
                                        let converted = Double(quickAmount) * exchangeRate
                                        HStack {
                                            Text("\(fromCurrency.symbol)\(quickAmount) \(fromCurrency.rawValue)")
                                                .font(.caption)
                                            Spacer()
                                            Text("=")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(toCurrency.symbol)\(String(format: "%.2f", converted)) \(toCurrency.rawValue)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
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
            CurrencyConverterInfoSheet()
        }
    }
    
    private func fillDemoDataAndCalculate() {
        amount = "100"
        fromCurrency = .usd
        toCurrency = .eur
        
        withAnimation {
            showResults = true
        }
    }
    
    private func clearAllData() {
        amount = ""
        fromCurrency = .usd
        toCurrency = .eur
        
        withAnimation {
            showResults = false
        }
    }
    
    private func shareResults() {
        let shareText = """
        Currency Conversion Results:
        Amount: \(fromCurrency.symbol)\(amount) \(fromCurrency.rawValue)
        Converted: \(toCurrency.symbol)\(String(format: "%.2f", convertedAmount)) \(toCurrency.rawValue)
        Exchange Rate: 1 \(fromCurrency.rawValue) = \(String(format: "%.4f", exchangeRate)) \(toCurrency.rawValue)
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

struct CurrencyConverterInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Currency Converter")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoSection(
                            title: "What it does",
                            content: """
                            • Converts amounts between different currencies
                            • Shows current exchange rates
                            • Provides quick conversion examples
                            • Supports 10 major world currencies
                            """
                        )
                        
                        InfoSection(
                            title: "How to use",
                            content: """
                            • Enter the amount you want to convert
                            • Select the currency you're converting from
                            • Select the currency you're converting to
                            • Tap Convert to see the result
                            • Use the swap button to reverse currencies
                            """
                        )
                        
                        InfoSection(
                            title: "Exchange Rates",
                            content: """
                            • Rates are approximate and for demonstration
                            • Real apps would fetch live rates from financial APIs
                            • Rates fluctuate constantly in real markets
                            • Always check current rates before making transactions
                            """
                        )
                        
                        InfoSection(
                            title: "Tips",
                            content: """
                            • Check multiple sources for exchange rates
                            • Be aware of transaction fees when exchanging money
                            • Consider using credit cards that don't charge foreign transaction fees
                            • Exchange larger amounts to reduce the impact of fees
                            • Monitor rates if planning a large exchange
                            """
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Currency Converter Help")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}