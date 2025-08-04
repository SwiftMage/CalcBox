import Foundation
import SwiftUI

struct Calculator: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: CalculatorCategory
    let icon: String
    let destination: AnyView
    
    init(name: String, description: String, category: CalculatorCategory, icon: String, destination: AnyView) {
        self.name = name
        self.description = description
        self.category = category
        self.icon = icon
        self.destination = destination
    }
}

extension Calculator {
    static let allCalculators: [Calculator] = [
        // Financial
        Calculator(
            name: "Compound Interest",
            description: "Calculate investment growth over time",
            category: .financial,
            icon: "chart.line.uptrend.xyaxis",
            destination: AnyView(CompoundInterestView())
        ),
        Calculator(
            name: "Mortgage Calculator",
            description: "Calculate monthly payments and total interest",
            category: .financial,
            icon: "house.fill",
            destination: AnyView(MortgageCalculatorView())
        ),
        Calculator(
            name: "Paycheck Info",
            description: "Calculate take-home pay after taxes",
            category: .financial,
            icon: "banknote.fill",
            destination: AnyView(PaycheckCalculatorView())
        ),
        Calculator(
            name: "Net Worth",
            description: "Track assets and liabilities",
            category: .financial,
            icon: "chart.pie.fill",
            destination: AnyView(NetWorthView())
        ),
        Calculator(
            name: "Investment Returns",
            description: "Track portfolio performance",
            category: .financial,
            icon: "chart.xyaxis.line",
            destination: AnyView(InvestmentReturnsView())
        ),
        Calculator(
            name: "Retirement Planning",
            description: "401k and IRA calculations",
            category: .financial,
            icon: "person.crop.circle.badge.clock",
            destination: AnyView(RetirementPlanningView())
        ),
        // Temporarily commented out due to build issues
        /*Calculator(
            name: "Retirement Savings",
            description: "How long will your savings last",
            category: .financial,
            icon: "hourglass",
            destination: AnyView(RetirementSavingsView())
        ),*/
        Calculator(
            name: "Loan Calculator",
            description: "Calculate loan payments and interest",
            category: .financial,
            icon: "creditcard.fill",
            destination: AnyView(LoanCalculatorView())
        ),
        Calculator(
            name: "Budget Planner",
            description: "50/30/20 rule budget calculator",
            category: .financial,
            icon: "envelope.fill",
            destination: AnyView(BudgetPlannerView())
        ),
        Calculator(
            name: "Inflation Calculator",
            description: "Calculate purchasing power over time",
            category: .financial,
            icon: "arrow.up.circle.fill",
            destination: AnyView(InflationCalculatorView())
        ),
        Calculator(
            name: "Debt Payoff Calculator",
            description: "Compare debt elimination strategies",
            category: .financial,
            icon: "creditcard.trianglebadge.exclamationmark",
            destination: AnyView(DebtPayoffView())
        ),
        Calculator(
            name: "Emergency Fund Calculator",
            description: "Plan and track your emergency savings",
            category: .financial,
            icon: "shield.lefthalf.filled.badge.checkmark",
            destination: AnyView(EmergencyFundView())
        ),
        
        // Travel
        Calculator(
            name: "Drive to Work",
            description: "Compare gas vs electric vehicle costs",
            category: .travel,
            icon: "car.2.fill",
            destination: AnyView(DriveToWorkView())
        ),
        Calculator(
            name: "EV Charging Cost",
            description: "Calculate electric vehicle charging expenses",
            category: .travel,
            icon: "bolt.car.fill",
            destination: AnyView(EVChargingCostView())
        ),
        Calculator(
            name: "Miles Per Gallon",
            description: "Track fuel efficiency",
            category: .travel,
            icon: "fuelpump.fill",
            destination: AnyView(MPGCalculatorView())
        ),
        Calculator(
            name: "Trip Time",
            description: "Estimate travel duration",
            category: .travel,
            icon: "timer",
            destination: AnyView(TripTimeView())
        ),
        Calculator(
            name: "Lease vs Buy Car",
            description: "Compare car leasing vs buying costs",
            category: .travel,
            icon: "car.2.circle.fill",
            destination: AnyView(LeaseVsBuyView())
        ),
        
        // Health
        Calculator(
            name: "Body Mass Index",
            description: "Calculate BMI and health category",
            category: .health,
            icon: "figure.stand",
            destination: AnyView(BMICalculatorView())
        ),
        Calculator(
            name: "Calorie Burning",
            description: "Exercise calorie calculator",
            category: .health,
            icon: "flame.fill",
            destination: AnyView(CalorieBurnView())
        ),
        Calculator(
            name: "Drinking Calories",
            description: "Alcohol calorie calculator",
            category: .health,
            icon: "wineglass.fill",
            destination: AnyView(DrinkingCaloriesView())
        ),
        Calculator(
            name: "One Rep Max",
            description: "Weight lifting calculator",
            category: .health,
            icon: "dumbbell.fill",
            destination: AnyView(OneRepMaxView())
        ),
        Calculator(
            name: "Pregnancy Due Date",
            description: "Calculate estimated due date",
            category: .health,
            icon: "heart.text.square.fill",
            destination: AnyView(PregnancyCalculatorView())
        ),
        Calculator(
            name: "Sleep Debt Calculator",
            description: "Track sleep deficit and plan recovery",
            category: .health,
            icon: "bed.double.fill",
            destination: AnyView(SleepDebtCalculatorView())
        ),
        Calculator(
            name: "Daily Calorie Calculator",
            description: "Calculate BMR, TDEE, and daily calorie needs",
            category: .health,
            icon: "flame.circle.fill",
            destination: AnyView(DailyCaloriesView())
        ),
        
        // Utilities
        Calculator(
            name: "Appliance Energy Cost",
            description: "Calculate electricity costs for appliances",
            category: .utilities,
            icon: "plug.fill",
            destination: AnyView(ApplianceEnergyCostView())
        ),
        Calculator(
            name: "Phone Cost Per Minute",
            description: "Calculate phone usage costs",
            category: .utilities,
            icon: "phone.fill",
            destination: AnyView(PhoneCostView())
        ),
        Calculator(
            name: "Monthly Bills",
            description: "Track recurring expenses",
            category: .utilities,
            icon: "doc.text.fill",
            destination: AnyView(MonthlyBillsView())
        ),
        Calculator(
            name: "Renting Cost",
            description: "Calculate true cost of renting",
            category: .utilities,
            icon: "building.2.fill",
            destination: AnyView(RentingCostView())
        ),
        Calculator(
            name: "Rent vs Buy Home",
            description: "Compare renting vs buying a home",
            category: .utilities,
            icon: "house.and.flag.fill",
            destination: AnyView(RentVsBuyHomeView())
        ),
        
        // Education
        Calculator(
            name: "GPA Calculator",
            description: "Calculate grade point average",
            category: .education,
            icon: "graduationcap.fill",
            destination: AnyView(GPACalculatorView())
        ),
        Calculator(
            name: "School Cost",
            description: "Calculate education expenses",
            category: .education,
            icon: "dollarsign.square.fill",
            destination: AnyView(SchoolCostView())
        ),
        
        // Lifestyle
        Calculator(
            name: "Tip Calculator",
            description: "Calculate tips and split bills",
            category: .lifestyle,
            icon: "percent",
            destination: AnyView(TipCalculatorView())
        ),
        Calculator(
            name: "Unit Converter",
            description: "Convert between units",
            category: .lifestyle,
            icon: "arrow.left.arrow.right",
            destination: AnyView(UnitConverterView())
        ),
        Calculator(
            name: "Currency Converter",
            description: "Convert between currencies",
            category: .lifestyle,
            icon: "dollarsign.arrow.circlepath",
            destination: AnyView(CurrencyConverterView())
        ),
        Calculator(
            name: "Sales Tax",
            description: "Calculate tax on purchases",
            category: .lifestyle,
            icon: "cart.fill",
            destination: AnyView(SalesTaxCalculatorView())
        ),
        Calculator(
            name: "Percentage Calculator",
            description: "Calculate percentages and changes",
            category: .lifestyle,
            icon: "percent.ar",
            destination: AnyView(PercentageCalculatorView())
        ),
        
        // Time & Date
        // TODO: Re-enable when Time calculator files are fixed
        /*
        Calculator(
            name: "Date Calculator",
            description: "Calculate days between dates",
            category: .time,
            icon: "calendar",
            destination: AnyView(DateCalculatorView())
        ),
        Calculator(
            name: "Time Zone Converter",
            description: "Convert between time zones",
            category: .time,
            icon: "globe",
            destination: AnyView(TimeZoneConverterView())
        ),
        Calculator(
            name: "Overtime Calculator",
            description: "Calculate overtime pay",
            category: .time,
            icon: "clock.badge.checkmark.fill",
            destination: AnyView(OvertimeCalculatorView())
        )
        */
    ]
}