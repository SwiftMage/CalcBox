import Foundation
import SwiftUI

enum CalculatorCategory: String, CaseIterable {
    case financial = "Financial"
    case travel = "Travel"
    case health = "Health"
    case utilities = "Utilities"
    case education = "Education"
    case lifestyle = "Lifestyle"
    case time = "Time & Date"
    
    var icon: String {
        switch self {
        case .financial: return "dollarsign.circle.fill"
        case .travel: return "car.fill"
        case .health: return "heart.fill"
        case .utilities: return "bolt.fill"
        case .education: return "graduationcap.fill"
        case .lifestyle: return "person.fill"
        case .time: return "clock.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .financial: return .green
        case .travel: return .blue
        case .health: return .red
        case .utilities: return .orange
        case .education: return .purple
        case .lifestyle: return .pink
        case .time: return .indigo
        }
    }
}