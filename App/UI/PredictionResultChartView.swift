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
            /// TX
            ForEach(predictor.txPoses) { pos in
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
            }.foregroundStyle(by: .value("key", Constant.Transmitters))
                .symbol(by: .value("key", Constant.Transmitters))
                .symbolSize(20)
        }.chartForegroundStyleScale([Constant.GroundTruth: Color(.systemGreen).opacity(0.8),
                                     Constant.Prediction: Color(.systemRed).opacity(0.8),
                                     Constant.Transmitters: Color(.systemBlue).opacity(0.8)])
            .chartSymbolScale([Constant.GroundTruth: .circle, Constant.Prediction: .cross, Constant.Transmitters: .asterisk])
            .chartXScale(domain: -15 ... 15)
            .chartYScale(domain: -15 ... 15)
            .chartLegend(position: .top, alignment: .topTrailing, spacing: 10)
            .chartXAxis{
                AxisMarks(values: .stride(by: 1)) { value in
                    if value.as(Int.self)! % 5 == 0 {
                        AxisGridLine().foregroundStyle(.black)
                        AxisTick().foregroundStyle(.black)
                        AxisValueLabel()
                    } else {
                        AxisGridLine()
                    }
                }
            }.chartYAxis{
                AxisMarks(values: .stride(by: 1)) { value in
                    if value.as(Int.self)! % 5 == 0 {
                        AxisGridLine().foregroundStyle(.black)
                        AxisTick().foregroundStyle(.black)
                        AxisValueLabel()
                    } else {
                        AxisGridLine()
                    }
                }
            }
            .frame(width: 410, height: 410)
    }
}
