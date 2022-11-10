//
//  PredictionSqureErrorChartView.swift
//  App
//
//  Created by x on 6/11/2022.
//

import SwiftUI
import Charts

struct PredictionPDFChartView: View {
    let data: [[Double]]

    var body: some View {
        Text("Prediction Probability Distribution of Position Error")
            .fontWeight(.semibold)
            .font(.caption)
        Chart (data, id: \.first) { point in
            BarMark( x: .value("x", point[0]),
                     y: .value("y", point[1]),
                     width: 2
            )
            .foregroundStyle(Color(.systemGreen).opacity(0.8))
        }
        .chartXAxis{
            AxisMarks(values: .stride(by: 1.0)) { value in
                if value.as(Int.self)! % 5 == 0 {
                    AxisGridLine().foregroundStyle(.black)
                    AxisTick().foregroundStyle(.black)
                } else {
                    AxisGridLine()
                }
                AxisValueLabel()
            }
        }
        .chartYAxis{
            AxisMarks() { value in
                AxisGridLine().foregroundStyle(.gray)
                AxisTick().foregroundStyle(.gray)
                AxisValueLabel()
            }
        }
        .chartXScale(domain: 0 ... 10)
        .frame(width: 410)
    }
}
