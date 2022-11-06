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
        }.chartForegroundStyleScale([Constant.GroundTruth: .green, Constant.Prediction: .red])
            .chartSymbolScale([Constant.GroundTruth: .circle, Constant.Prediction: .cross])
            .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: -6.0, upper: 6)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: -6.0, upper: 6)))
            .chartLegend(position: .topTrailing, alignment: .topTrailing, spacing: 10)
            .chartXAxis{
                AxisMarks() {
                    AxisTick()
                    AxisGridLine()
                }
            }
            .frame(width: 400, height: 400)
    }
}
