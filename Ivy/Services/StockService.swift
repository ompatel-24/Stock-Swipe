//
//  StockService.swift
//  Ivy
//

import Foundation
import SwiftData

@Observable
class StockService {
    static let shared = StockService()
    
    private init() {}
    
    func generateMockStocks(excludingSymbols: Set<String> = []) -> [Stock] {
        let allMockStocks = [
            ("OKLO", "Oklo Inc.", 71.49, 76.58),
            ("PLTR", "Palantir Technologies", 154.27, 158.37),
            ("NVDA", "NVIDIA Corporation", 173.72, 177.85),
            ("AMD", "Advanced Micro Devices", 171.70, 176.28),
            ("RBLX", "Roblox Corporation", 125.03, 137.73),
            ("COIN", "Coinbase Global", 314.69, 377.98),
            ("RIVN", "Rivian Automotive", 12.38, 12.87),
            ("SOFI", "SoFi Technologies", 21.23, 22.59),
            ("LCID", "Lucid Group", 2.42, 2.46),
            ("HOOD", "Robinhood Markets", 99.90, 103.06),
            ("NET", "Cloudflare Inc.", 200.11, 207.54),
            ("SHOP", "Shopify Inc.", 118.60, 122.21),
            ("TSLA", "Tesla Inc.", 342.05, 335.12),
            ("AAPL", "Apple Inc.", 234.20, 231.16),
            ("MSFT", "Microsoft Corporation", 445.78, 442.91),
            ("GOOGL", "Alphabet Inc.", 178.32, 175.68),
            ("META", "Meta Platforms", 478.65, 472.13),
            ("NFLX", "Netflix Inc.", 721.45, 715.22),
            ("UBER", "Uber Technologies", 89.34, 87.52),
            ("SPOT", "Spotify Technology", 412.77, 408.93),
            ("SQ", "Block Inc.", 88.92, 85.74),
            ("PYPL", "PayPal Holdings", 78.45, 76.89),
            ("TWLO", "Twilio Inc.", 78.23, 76.11),
            ("DOCU", "DocuSign Inc.", 65.78, 63.45),
            ("ZM", "Zoom Video Communications", 89.12, 87.34),
            ("CRWD", "CrowdStrike Holdings", 378.56, 374.22),
            ("SNOW", "Snowflake Inc.", 112.89, 109.76),
            ("DDOG", "Datadog Inc.", 134.56, 131.87),
            ("MDB", "MongoDB Inc.", 298.45, 294.67),
            ("WDAY", "Workday Inc.", 234.78, 231.92)
        ]
        
        let filteredStocks = allMockStocks.filter { !excludingSymbols.contains($0.0) }
        
        let selectedStocks = Array(filteredStocks.prefix(12))
        
        let mockStocks = selectedStocks.map { (symbol, name, current, previous) in
            let priceVariation = Double.random(in: 0.95...1.05)
            let adjustedCurrent = current * priceVariation
            let adjustedPrevious = previous * priceVariation
            
            let stock = Stock(
                symbol: symbol,
                companyName: name,
                currentPrice: adjustedCurrent,
                previousClose: adjustedPrevious
            )
            
            stock.discoveryScore = Double.random(in: 0...100) // new model MATHU
            
            return stock
        }
        
        return mockStocks
    }
}

extension StockService {
    func getRecommendedStocks(basedOn likedStocks: [Stock], dislikedStocks: [Stock], allStocks: [Stock]) -> [Stock] {
        var scoredStocks: [(stock: Stock, score: Double)] = []
        
        for stock in allStocks {
            guard !stock.isLiked && !stock.isDisliked else { continue }
                                    
            scoredStocks.append((stock: stock, score: stock.discoveryScore))
        }
        
        return scoredStocks
            .sorted { $0.score > $1.score }
            .prefix(10)
            .map { $0.stock }
    }
}
