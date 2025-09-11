//
//  PortfolioView.swift
//  Ivy
//

import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Stock> { $0.isLiked == true }, sort: \Stock.likedAt, order: .reverse) 
    private var likedStocks: [Stock]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if likedStocks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Liked Stocks Yet")
                                .font(.title2.bold())
                            
                            Text("Start discovering stocks to build your portfolio of interests!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        ForEach(likedStocks) { stock in
                            PortfolioStockCard(stock: stock) {
                                removeFromPortfolio(stock)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Your Portfolio")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func removeFromPortfolio(_ stock: Stock) {
        withAnimation {
            stock.isLiked = false
            stock.likedAt = nil
            try? modelContext.save()
        }
    }
}

struct PortfolioStockCard: View {
    let stock: Stock
    let onRemove: () -> Void
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.symbol)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(stock.companyName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(stock.currentPrice, specifier: "%.2f")")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: stock.isGaining ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text("\(stock.priceChangePercent, specifier: "%.2f")%")
                            .font(.caption.bold())
                    }
                    .foregroundColor(stock.isGaining ? .green : .red)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sector")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(stock.sector ?? "N/A")
                        .font(.footnote.bold())
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Discovery Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(stock.discoveryScore))")
                        .font(.footnote.bold())
                        .foregroundColor(scoreColor(stock.discoveryScore))
                }
                
                Spacer()
                
                Button(action: {
                    showingAlert = true
                }) {
                    Image(systemName: "heart.slash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
            
            if let companyDescription = stock.companyDescription {
                Text(companyDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Remove from Portfolio", isPresented: $showingAlert) {
            Button("Remove", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove \(stock.symbol) from your portfolio?")
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green }
        else if score >= 60 { return .orange }
        else { return .red }
    }
}

#Preview {
    PortfolioView()
        .modelContainer(for: Stock.self, inMemory: true)
        .environment(InvestmentConfig.shared)
}
