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
    let movingAvgErr: Double?

    var body: some View {
        Text("Probability Distribution of Position Error (meters)")
            .fontWeight(.semibold)
            .font(.caption)
        Chart() {
            ForEach(data, id: \.first) { point in
                BarMark( x: .value("x", point[0]),
                         y: .value("y", point[1]),
                         width: 2
                )
                .foregroundStyle(Color(.systemGreen).opacity(0.8))
            }
//            if let x = movingAvgErr, let y = self.getProbability(x:x) {
//                BarMark(
//                    x: .value("x", x),
//                    y: .value("y", y),
//                    width: 2
//                )
//                .foregroundStyle(Color(.systemRed).opacity(0.8))
//            }
            
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
    
    func getProbability(x:Double) -> Double? {
        var dict:[Double:Double] = [:]
        self.data.forEach { point in
            let key = point[0]
            let val = point[1]
            dict[key] = val
        }
        var cloestKey:Double = 0
        var cloestDif:Double = Double.infinity
        for key in Array(dict.keys) {
            let dif = abs(x - key)
            if dif < cloestDif {
                cloestDif = dif
                cloestKey = key
            }
        }
        return dict[cloestKey]
    }
}
