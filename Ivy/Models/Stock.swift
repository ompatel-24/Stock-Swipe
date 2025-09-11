//
//  Stock.swift
//  Ivy
//

import Foundation
import SwiftData

@Model
final class Stock {
    var symbol: String
    var companyName: String
    var currentPrice: Double
    var previousClose: Double
    var marketCap: Double?
    var peRatio: Double?
    var dividendYield: Double?
    var weekLow52: Double?
    var weekHigh52: Double?
    var volume: Int?
    var averageVolume: Int?
    var sector: String?
    var industry: String?
    var companyDescription: String?
    var logoURL: String?
    var website: String?
    
    var isLiked: Bool
    var isDisliked: Bool
    var viewedAt: Date?
    var likedAt: Date?
    var dislikedAt: Date?
    
    var discoveryScore: Double
    var momentum: Double
    var volatility: Double
    var sentiment: Double
    
    var priceChange: Double {
        return currentPrice - previousClose
    }
    
    var priceChangePercent: Double {
        guard previousClose > 0 else { return 0 }
        return (priceChange / previousClose) * 100
    }
    
    var isGaining: Bool {
        return priceChange > 0
    }
    
    init(symbol: String, companyName: String, currentPrice: Double, previousClose: Double) {
        self.symbol = symbol.uppercased()
        self.companyName = companyName
        self.currentPrice = currentPrice
        self.previousClose = previousClose
        self.isLiked = false
        self.isDisliked = false
        self.discoveryScore = 0.0
        self.momentum = 0.0
        self.volatility = 0.0
        self.sentiment = 0.0
    }
}
