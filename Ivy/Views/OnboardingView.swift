//
//  OnboardingView.swift
//  Ivy
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(InvestmentConfig.self) private var config
    
    @State private var tempRiskTolerance: Double = 0.5
    @State private var tempInvestmentHorizon: Double = 5
    @State private var tempInvestmentAmount: Double = 0.1
    @State private var tempLiquidityNeeds: Double = 0.5
    @State private var tempSelectedSectors: Set<IndustrySector> = []
    @State private var showingSectorPicker = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    welcomeHeader
                    configurationSections
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
        .interactiveDismissDisabled()
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Let's Set Up Your Investment Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Help us personalize your stock discovery experience by sharing your investment preferences. This will help us recommend stocks that match your goals.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }
    
    private var configurationSections: some View {
        VStack(spacing: 44) {
            riskToleranceSection
            investmentHorizonSection
            investmentAmountSection
            liquidityNeedsSection
            industrySectorsSection
        }
    }
    
    private var riskToleranceSection: some View {
        OnboardingSliderSection(
            title: "Risk Tolerance",
            subtitle: "How comfortable are you with investment risk?",
            value: $tempRiskTolerance,
            range: 0.1...1.0,
            step: 0.05,
            currentValueText: "\(Int(tempRiskTolerance * 100))%",
            lowLabel: "Conservative",
            highLabel: "Aggressive"
        )
    }
    
    private var investmentHorizonSection: some View {
        OnboardingSliderSection(
            title: "Investment Horizon",
            subtitle: "How long do you plan to hold investments?",
            value: $tempInvestmentHorizon,
            range: 1...30,
            step: 1,
            currentValueText: "\(Int(tempInvestmentHorizon)) year\(tempInvestmentHorizon == 1 ? "" : "s")",
            lowLabel: "Short-term",
            highLabel: "Long-term"
        )
    }
    
    private var investmentAmountSection: some View {
        OnboardingSliderSection(
            title: "Investment Amount",
            subtitle: "What's your typical investment size?",
            value: $tempInvestmentAmount,
            range: 0.1...1.0,
            step: 0.05,
            currentValueText: "$\(formatInvestmentAmount(tempInvestmentAmount))",
            lowLabel: "Smaller",
            highLabel: "Larger"
        )
    }
    
    private var liquidityNeedsSection: some View {
        OnboardingSliderSection(
            title: "Liquidity Preference",
            subtitle: "How quickly might you need access to your investments?",
            value: $tempLiquidityNeeds,
            range: 0.1...1.0,
            step: 0.05,
            currentValueText: liquidityDescription(tempLiquidityNeeds),
            lowLabel: "Flexible",
            highLabel: "Quick access"
        )
    }
    
    private var industrySectorsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Industry Interests")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Which industries interest you most? (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                showingSectorPicker = true
            }) {
                HStack {
                    Text(tempSelectedSectors.isEmpty ? "Choose industries" : "Tap to modify")
                        .foregroundColor(tempSelectedSectors.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if !tempSelectedSectors.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(tempSelectedSectors.prefix(6)), id: \.self) { sector in
                        SectorTag(sector: sector)
                    }
                    
                    if tempSelectedSectors.count > 6 {
                        Text("+\(tempSelectedSectors.count - 6) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSectorPicker) {
            SectorPickerView(selectedSectors: $tempSelectedSectors)
        }
    }
    
    private func loadCurrentValues() {
        tempRiskTolerance = config.riskTolerance
        tempInvestmentHorizon = config.investmentHorizon
        tempInvestmentAmount = config.investmentAmount
        tempLiquidityNeeds = config.liquidityNeeds
        tempSelectedSectors = config.selectedSectors
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            config.riskTolerance = tempRiskTolerance
            config.investmentHorizon = tempInvestmentHorizon
            config.investmentAmount = tempInvestmentAmount
            config.liquidityNeeds = tempLiquidityNeeds
            config.selectedSectors = tempSelectedSectors
            config.hasCompletedOnboarding = true
        }
        
        dismiss()
    }
    
    private func formatInvestmentAmount(_ amount: Double) -> String {
        let value = Int(amount * 1000)
        if value >= 1000 {
            return "1M+"
        } else {
            return "\(value)K"
        }
    }
    
    private func liquidityDescription(_ value: Double) -> String {
        switch value {
        case 0.1..<0.4: return "Low"
        case 0.4..<0.7: return "Medium"
        default: return "High"
        }
    }
}

struct OnboardingSliderSection: View {
    let title: String
    let subtitle: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let currentValueText: String
    let lowLabel: String
    let highLabel: String
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(currentValueText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                Slider(value: $value, in: range, step: step)
                    .tint(Color.blue)
                    .animation(.easeOut(duration: 0.15), value: value)
                
                HStack {
                    Text(lowLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(highLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(InvestmentConfig.shared)
}
