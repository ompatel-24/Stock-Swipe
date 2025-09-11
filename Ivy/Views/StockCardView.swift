//
//  StockCardView.swift
//  Ivy
//

import SwiftUI

struct StockCardView: View {
    let stock: Stock
    @State private var dragOffset = CGSize.zero
    @State private var isLiked = false
    @State private var isDisliked = false
    @State private var isFlipped = false
    @State private var flipDegree: Double = 0
    
    let onLike: () -> Void
    let onDislike: () -> Void
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                frontCardContent
            }
            .opacity(flipDegree < 90 ? 1 : 0)
            .rotation3DEffect(.degrees(flipDegree), axis: (x: 0, y: 1, z: 0))
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                backCardContent
            }
            .opacity(flipDegree >= 90 ? 1 : 0)
            .rotation3DEffect(.degrees(flipDegree + 180), axis: (x: 0, y: 1, z: 0))
            
            overlayIcons
        }
        .frame(width: 320, height: 500)
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width) / 10))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.8)) {
                isFlipped.toggle()
                flipDegree = isFlipped ? 180 : 0
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let swipeThreshold: CGFloat = 100
                    
                    if value.translation.width > swipeThreshold {
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: 500, height: 0)
                            isLiked = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onLike()
                        }
                    } else if value.translation.width < -swipeThreshold {
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragOffset = CGSize(width: -500, height: 0)
                            isDisliked = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDislike()
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
    
    private var frontCardContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Text(stock.symbol)
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(stock.currentPrice, specifier: "%.2f")")
                            .font(.title2.bold())
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
                
                Text(stock.companyName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetricView(title: "Market Cap", 
                          value: formatMarketCap(stock.marketCap))
                
                MetricView(title: "P/E Ratio", 
                          value: stock.peRatio != nil ? String(format: "%.1f", stock.peRatio!) : "N/A")
                
                MetricView(title: "Volume", 
                          value: formatVolume(stock.volume))
                
                MetricView(title: "52W Range", 
                          value: format52WeekRange(low: stock.weekLow52, high: stock.weekHigh52))
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sector")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(stock.sector ?? "N/A")
                        .font(.footnote.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Industry")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(stock.industry ?? "N/A")
                        .font(.footnote.bold())
                        .foregroundColor(.primary)
                }
            }
            
            if let companyDescription = stock.companyDescription {
                Text(companyDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack {
                    Text("Discovery Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: stock.discoveryScore / 100)
                            .stroke(scoreColor(stock.discoveryScore), lineWidth: 4)
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(stock.discoveryScore))")
                            .font(.caption.bold())
                            .foregroundColor(scoreColor(stock.discoveryScore))
                    }
                }
                
                HStack {
                    Image(systemName: "hand.tap")
                        .font(.footnote)
                        .foregroundColor(.blue)
                    Text("Tap to flip for more details")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .opacity(0.7)
            }
        }
        .padding(20)
    }
    
    private var backCardContent: some View {
        Text("More info here")
    }
    
    private var overlayIcons: some View {
        Group {
            if dragOffset.width > 50 {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .opacity(min(1.0, Double(dragOffset.width - 50) / 100))
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            } else if dragOffset.width < -50 {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .opacity(min(1.0, Double(-dragOffset.width - 50) / 100))
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green }
        else if score >= 60 { return .orange }
        else { return .red }
    }
    
    private func formatMarketCap(_ marketCap: Double?) -> String {
        guard let marketCap = marketCap else { return "N/A" }
        
        if marketCap >= 1_000_000_000_000 {
            return String(format: "%.1fT", marketCap / 1_000_000_000_000)
        } else if marketCap >= 1_000_000_000 {
            return String(format: "%.1fB", marketCap / 1_000_000_000)
        } else if marketCap >= 1_000_000 {
            return String(format: "%.1fM", marketCap / 1_000_000)
        }
        return String(format: "%.0f", marketCap)
    }
    
    private func formatVolume(_ volume: Int?) -> String {
        guard let volume = volume else { return "N/A" }
        
        if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        }
        return String(volume)
    }
    
    private func format52WeekRange(low: Double?, high: Double?) -> String {
        guard let low = low, let high = high else { return "N/A" }
        return String(format: "%.1f - %.1f", low, high)
    }
}

struct MetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.footnote.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StockCardView(
        stock: Stock(symbol: "OKLO", companyName: "Oklo Inc.", currentPrice: 24.50, previousClose: 10.30),
        onLike: {},
        onDislike: {}
    )
}
