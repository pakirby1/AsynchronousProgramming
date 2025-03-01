//
//  LineChart.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/27/25.
//

import Foundation
import SwiftUI
import Charts

struct LineChartPoint : Hashable {
    let x: Date
    let y: Double
}

struct LineChartView : View {
    let data: [LineChartPoint]
    
    var body: some View {
        Text("LineChart")
        GroupBox("Prices") {
            Chart {
                ForEach(data, id: \.self) { price in
                    LineMark(x: .value("Date", price.x), y: .value("Price", price.y))
                }
            }
        }
    }
}
