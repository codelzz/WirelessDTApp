//
//  PredictionSqureErrorChartView.swift
//  App
//
//  Created by x on 6/11/2022.
//

import SwiftUI
import Charts

struct PredictionPDFChartView: View {
    let data: [[Double]]?

    var body: some View {
        Text("Prediction Probability Distribution of Position Error")
            .fontWeight(.semibold)
            .font(.caption)
        if let data = data {
            Chart (data, id: \.first) { point in
                BarMark( x: .value("x", point[0]),
                         y: .value("y", point[1]),
                         width: 2
                )
                .foregroundStyle(Color(.systemGreen))
            }
        }
        else {
            Chart () {
            }.chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: 10)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: 1)))
        }
    }
}
