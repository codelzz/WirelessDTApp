//
//  PredictionMapView.swift
//  App
//
//  Created by x on 6/11/2022.
//

import SwiftUI
import Charts

struct PredictionResultChartView: View {
    @EnvironmentObject var predictor:Predictor

    var body: some View {
        Text("Real-time Prediction")
            .fontWeight(.semibold)
            .font(.caption)
        /// Chart
        Chart {
            /// IMPORTANT: We need to swap x-y to match the game map in unreal
            /// Ground Truth
            ForEach(predictor.realPoses) { pos in
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
            }.foregroundStyle(by: .value("key", Constant.GroundTruth))
                .symbol(by: .value("key", Constant.GroundTruth))
                .symbolSize(20)
            /// Prediction
            ForEach(predictor.predPoses) { pos in
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
            }.foregroundStyle(by: .value("key", Constant.Prediction))
                .symbol(by: .value("key", Constant.Prediction))
                .symbolSize(20)
        }.chartForegroundStyleScale([Constant.GroundTruth: Color(.systemGreen).opacity(0.8), Constant.Prediction: Color(.systemRed).opacity(0.8)])
            .chartSymbolScale([Constant.GroundTruth: .circle, Constant.Prediction: .cross])
            .chartXScale(domain: -6 ... 6)
            .chartYScale(domain: -6 ... 6)
            .chartLegend(position: .top, alignment: .topTrailing, spacing: 10)
            .chartXAxis{
                AxisMarks(values: .stride(by: 1)) { value in
                    if value.as(Int.self)! % 5 == 0 {
                        AxisGridLine().foregroundStyle(.black)
                        AxisTick().foregroundStyle(.black)
                    } else {
                        AxisGridLine()
                    }
                    AxisValueLabel()
                }
            }.chartYAxis{
                AxisMarks(values: .stride(by: 1)) { value in
                    if value.as(Int.self)! % 5 == 0 {
                        AxisGridLine().foregroundStyle(.black)
                        AxisTick().foregroundStyle(.black)
                    } else {
                        AxisGridLine()
                    }
                    AxisValueLabel()
                }
            }
            .frame(width: 410, height: 410)
    }
}
