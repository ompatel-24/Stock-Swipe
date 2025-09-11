//
//  InvestmentConfig.swift
//  Ivy
//

import Foundation

@Observable
class InvestmentConfig {
    static let shared = InvestmentConfig()
    
    var riskTolerance: Double = 0.5
    var investmentHorizon: Double = 5
    var investmentAmount: Double = 0.1
    var liquidityNeeds: Double = 0.5
    var selectedSectors: Set<IndustrySector> = []
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }
    
    
    func resetOnboarding() {
        riskTolerance = 0.5
        investmentHorizon = 5
        investmentAmount = 0.1
        liquidityNeeds = 0.5
        selectedSectors = []
        hasCompletedOnboarding = false
    }
    private init() {}
}

enum IndustrySector: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case financials = "Financials"
    case consumerDiscretionary = "Consumer Discretionary"
    case communication = "Communication"
    case industrials = "Industrials"
    case consumerStaples = "Consumer Staples"
    case energy = "Energy"
    case utilities = "Utilities"
    case realEstate = "Real Estate"
    case materials = "Materials"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .technology:
            return "laptopcomputer"
        case .healthcare:
            return "heart.text.square"
        case .financials:
            return "banknote"
        case .consumerDiscretionary:
            return "cart"
        case .communication:
            return "antenna.radiowaves.left.and.right"
        case .industrials:
            return "hammer"
        case .consumerStaples:
            return "basket"
        case .energy:
            return "bolt"
        case .utilities:
            return "lightbulb"
        case .realEstate:
            return "house"
        case .materials:
            return "cube.box"
        }
    }
}
