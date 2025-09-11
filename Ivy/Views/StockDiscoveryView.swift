//
//  StockDiscoveryView.swift
//  Ivy
//

import SwiftUI
import SwiftData

struct StockDiscoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(InvestmentConfig.self) private var investmentConfig
    @Query private var stocks: [Stock]
    @State private var viewModel = StockDiscoveryViewModel()
    @State private var currentStockIndex = 0
    @State private var showingOnboarding = false
    @State private var showingInvestmentConfig = false
    
    private var likedStocks: [Stock] {
        stocks.filter { $0.isLiked }
    }
    
    private var dislikedStocks: [Stock] {
        stocks.filter { $0.isDisliked }
    }
    
    private var unviewedStocks: [Stock] {
        stocks.filter { !$0.isLiked && !$0.isDisliked }
    }
    
    private var allKnownSymbols: Set<String> {
        Set(stocks.map { $0.symbol })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    
                    stockCardsView
                    
                    actionButtonsView
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Options") {
                        showingInvestmentConfig = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.refreshStockData() // does nothing rn
                    }
                }
            }
            .sheet(isPresented: $showingInvestmentConfig) {
                InvestmentConfigView()
                    .environment(InvestmentConfig.shared)
            }
        }
        .onAppear {
            setupInitialStocks()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Portfolio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(likedStocks.count) stocks")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(unviewedStocks.count) stocks")
                        .font(.headline.bold())
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("Loading recommendations...")
                    .padding()
            }
        }
    }
    
    private var stockCardsView: some View {
        ZStack {
            if unviewedStocks.isEmpty {
                emptyStateView
            } else {
                ForEach(Array(unviewedStocks.prefix(3).enumerated()), id: \.element.id) { index, stock in
                    StockCardView(
                        stock: stock,
                        onLike: { likeStock(stock) },
                        onDislike: { dislikeStock(stock) }
                    )
                    .zIndex(Double(3 - index))
                    .offset(y: CGFloat(index * 5))
                    .scaleEffect(1.0 - (CGFloat(index) * 0.05))
                }
            }
        }
        .frame(height: 500)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 40) {
            Button(action: {
                if let currentStock = unviewedStocks.first {
                    dislikeStock(currentStock)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            .disabled(unviewedStocks.isEmpty)
            
            Button(action: {
                if let currentStock = unviewedStocks.first {
                    likeStock(currentStock)
                }
            }) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .disabled(unviewedStocks.isEmpty)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("All Caught Up")
                .font(.title2.bold())
            
            Text("You've reviewed all available stocks. Check your portfolio or refresh for new recommendations.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate More") {
                generateMoreStocks()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func setupInitialStocks() {
        if stocks.isEmpty {
            let mockStocks = StockService.shared.generateMockStocks(excludingSymbols: allKnownSymbols)
            for stock in mockStocks {
                modelContext.insert(stock)
            }
            try? modelContext.save()
        }
    }
    
    private func likeStock(_ stock: Stock) {
        withAnimation(.easeInOut(duration: 0.3)) {
            stock.isLiked = true
            stock.likedAt = Date()
            stock.viewedAt = Date()
            try? modelContext.save()
        }
        
        viewModel.generateRecommendations(
            basedOn: likedStocks,
            dislikedStocks: dislikedStocks,
            allStocks: Array(stocks)
        )
    }
    
    private func dislikeStock(_ stock: Stock) {
        withAnimation(.easeInOut(duration: 0.3)) {
            stock.isDisliked = true
            stock.dislikedAt = Date()
            stock.viewedAt = Date()
            try? modelContext.save()
        }
    }
    
    private func generateMoreStocks() {
        let additionalStocks = StockService.shared.generateMockStocks(excludingSymbols: allKnownSymbols)
        if additionalStocks.isEmpty {
            showNoMoreStocksAlert()
            return
        }
        
        for stock in additionalStocks {
            modelContext.insert(stock)
        }
        try? modelContext.save()
    }
    
    private func showNoMoreStocksAlert() {
        print("No more unique stocks available to generate")
    }
}


struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    StockDiscoveryView()
        .modelContainer(for: Stock.self, inMemory: true)
        .environment(InvestmentConfig.shared)
}
