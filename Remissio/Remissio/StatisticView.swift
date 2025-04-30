//
//  StatisticView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 17/04/25.
//

import SwiftUI

// Statistic View (per Sintomi, Scariche, Sangue)
struct StatisticView: View {
    var title: String
    @Binding var percent: Double
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            ProgressBar(value: percent, color: color)
                .frame(height: 20)
            
            Text("\(Int(percent))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

// Progress Bar
struct ProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color.gray.opacity(0.3)
                    .cornerRadius(8)
                
                Color.blue
                    .frame(width: CGFloat(value / 100) * geometry.size.width)
                    .cornerRadius(8)
            }
            .frame(height: 10)
        }
    }
}
