//
//  StockDiscoveryViewModel.swift
//  Ivy
//

import Foundation
import SwiftData

@Observable
class StockDiscoveryViewModel {
    private let stockService = StockService.shared
    var currentRecommendations: [Stock] = []
    var isLoading = false
    var error: String?
    
    func generateRecommendations(basedOn likedStocks: [Stock], dislikedStocks: [Stock], allStocks: [Stock]) {
        isLoading = true
        error = nil
        
        self.currentRecommendations = self.stockService.getRecommendedStocks(
            basedOn: likedStocks,
            dislikedStocks: dislikedStocks,
            allStocks: allStocks
        )
        self.isLoading = false    }
    
    func refreshStockData() {
        // isLoading = true
        // for loop
        // isLoading = false
        // fetch more api ig
    }
}
