//
//  PredictionSqureErrorChartView.swift
//  App
//
//  Created by x on 6/11/2022.
//

import SwiftUI
import Charts

struct PredictionSqureErrorChartView: View {
    let data: [[Double]]?

    var body: some View {
        if let data = data {
            Chart (data, id: \.first) { point in
                BarMark( x: .value("x", point[0]),
                         y: .value("y", point[1]),
                         width: 2
                )
                .foregroundStyle(Color(.blue))
            }
        }
        else {
            Chart () {
            }.chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: 10.0)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: 1.0)))
        }
    }
}
