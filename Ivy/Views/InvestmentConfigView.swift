//
//  InvestmentConfigView.swift
//  Ivy
//

import SwiftUI

struct InvestmentConfigView: View {
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
                    headerView
                    configurationSections
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.body)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveConfiguration()
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Investment Profile")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set your preferences to get personalized recommendations")
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 10)
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
        SliderSection(
            title: "Risk Tolerance",
            value: $tempRiskTolerance,
            range: 0.1...1.0,
            step: 0.05,
            currentValueText: "\(Int(tempRiskTolerance * 100))%",
            lowLabel: "Conservative",
            highLabel: "Aggressive"
        )
    }
    
    private var investmentHorizonSection: some View {
        SliderSection(
            title: "Investment Horizon",
            value: $tempInvestmentHorizon,
            range: 1...30,
            step: 1,
            currentValueText: "\(Int(tempInvestmentHorizon)) year\(tempInvestmentHorizon == 1 ? "" : "s")",
            lowLabel: "Short-term",
            highLabel: "Long-term"
        )
    }
    
    private var investmentAmountSection: some View {
        SliderSection(
            title: "Investment Amount",
            value: $tempInvestmentAmount,
            range: 0.1...1.0,
            step: 0.05,
            currentValueText: "$\(formatInvestmentAmount(tempInvestmentAmount))",
            lowLabel: "Smaller",
            highLabel: "Larger"
        )
    }
    
    private var liquidityNeedsSection: some View {
        SliderSection(
            title: "Liquidity Preference",
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
            HStack {
                Text("Industry Focus")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if !tempSelectedSectors.isEmpty {
                    Text("\(tempSelectedSectors.count) selected")
                        .font(.subheadline)
                }
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
    
    private func saveConfiguration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            config.riskTolerance = tempRiskTolerance
            config.investmentHorizon = tempInvestmentHorizon
            config.investmentAmount = tempInvestmentAmount
            config.liquidityNeeds = tempLiquidityNeeds
            config.selectedSectors = tempSelectedSectors
        }
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

struct SliderSection: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let currentValueText: String
    let lowLabel: String
    let highLabel: String
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(currentValueText)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            VStack(spacing: 16) {
                Slider(value: $value, in: range, step: step)
                    .tint(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .animation(.easeOut(duration: 0.15), value: value)
                
                HStack {
                    Text(lowLabel)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(highLabel)
                        .font(.caption)
                }
            }
        }
    }
}

struct SectorTag: View {
    let sector: IndustrySector
    
    var body: some View {
        HStack(spacing: 4) {
            Text(sector.rawValue)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(.quaternarySystemFill))
//        .foregroundColor(.blue)
        .cornerRadius(6)
    }
}

struct SectorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSectors: Set<IndustrySector>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(IndustrySector.allCases) { sector in
                    SectorRow(
                        sector: sector,
                        isSelected: selectedSectors.contains(sector)
                    ) { isSelected in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected {
                                selectedSectors.insert(sector)
                            } else {
                                selectedSectors.remove(sector)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Industries")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct SectorRow: View {
    let sector: IndustrySector
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack(spacing: 16) {
                Image(systemName: sector.icon)
                    .font(.body)
                    .frame(width: 20)
                
                Text(sector.rawValue)
                    .font(.body)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    InvestmentConfigView()
        .environment(InvestmentConfig.shared)
}
