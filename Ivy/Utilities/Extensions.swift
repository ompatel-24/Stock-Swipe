//
//  Extensions.swift
//  Ivy
//

import Foundation
import SwiftUI

extension Double {
    func formattedAsPrice() -> String {
        return String(format: "%.2f", self)
    }
    
    func formattedAsPercentage() -> String {
        return String(format: "%.2f%%", self)
    }
}

extension Color {
    static let stockGreen = Color.green
    static let stockRed = Color.red
    
    static func stockChangeColor(for change: Double) -> Color {
        return change >= 0 ? .stockGreen : .stockRed
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
