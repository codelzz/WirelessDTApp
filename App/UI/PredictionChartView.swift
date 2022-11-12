//
//  PredictionMapView.swift
//  App
//
//  Created by x on 6/11/2022.
//

import SwiftUI
import Charts

struct PredictionResultChartView: View {
    @ObservedObject var dataManager = DataManager.shared()
    let trajectory:[Position]
    let movingAverageTrajectory: [Position]

    
    var body: some View {
        Text("Real-time Prediction")
            .fontWeight(.semibold)
            .font(.caption)
        /// Chart
        Chart {
            //MARK: [IMPORTANT] We need to swap x-y to match the game map in UE
            /// Ground Truth
            if let pos = dataManager.realPos {
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
                    .foregroundStyle(by: .value("key", Constant.GroundTruth))
                    .symbol(by: .value("key", Constant.GroundTruth))
                    .symbolSize(20)
            }
            /// Ground Truth Trajectory
            ForEach(dataManager.realTrajectory) { pos in
                LineMark(x: .value("x", pos.y), y: .value("y", pos.x))
                    .interpolationMethod(.cardinal)
            }.foregroundStyle(by: .value("key", Constant.GroundTruthTrajectory))
                .symbol(by: .value("key", Constant.GroundTruthTrajectory))
                .symbolSize(20)
            /// Prediction
            ForEach(trajectory) { pos in
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
            }.foregroundStyle(by: .value("key", Constant.Prediction))
                .symbol(by: .value("key", Constant.Prediction))
                .symbolSize(20)
            /// Moving Average
            if movingAverageTrajectory.count > 0 {
                /// MA
                if let pos = movingAverageTrajectory.last {
                    PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
                        .foregroundStyle(by: .value("key", Constant.PredictionMovingAverage))
                        .symbol(by: .value("key", Constant.PredictionMovingAverage))
                        .symbolSize(100)
                }
                /// MA Trajectory
                ForEach(movingAverageTrajectory) { pos in
                    LineMark(x: .value("x", pos.y), y: .value("y", pos.x))
                }.foregroundStyle(by: .value("key", Constant.PredictionMovingAverageTrajectory))
                    .symbol(by: .value("key", Constant.PredictionMovingAverageTrajectory))
                    .symbolSize(10)
            }
            /// TX
            ForEach(dataManager.txs.getAllPositions()) { pos in
                PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
            }.foregroundStyle(by: .value("key", Constant.Transmitters))
                .symbol(by: .value("key", Constant.Transmitters))
                .symbolSize(20)
        }.chartForegroundStyleScale([Constant.GroundTruth: Color(.systemGreen).opacity(1.0),
                                     Constant.GroundTruthTrajectory: Color(.systemGreen).opacity(0.3),
                                     Constant.Prediction: Color(.systemRed).opacity(0.5),
                                     Constant.PredictionMovingAverage: Color(.systemRed).opacity(1.0),
                                     Constant.PredictionMovingAverageTrajectory: Color(.systemGray).opacity(0.3),
                                     Constant.Transmitters: Color(.systemBlue).opacity(1.0)])
            .chartSymbolScale([Constant.GroundTruth: .circle,
                               Constant.GroundTruthTrajectory: .circle,
                               Constant.Prediction: .cross,
                               Constant.PredictionMovingAverage: .cross,
                               Constant.PredictionMovingAverageTrajectory: .circle,
                               Constant.Transmitters: .asterisk])
            .chartXScale(domain: -11 ... 11)
            .chartYScale(domain: -11 ... 11)
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
