//
//  DeepLearningView.swift
//  App
//
//  Created by x on 8/11/2022.
//

import SwiftUI
import Charts

struct DeepLearningView: View {
    @EnvironmentObject var dlpredictor:RNNPredictor

    var body: some View {
        VStack{
            /// Header
            HeaderView(title: Constant.DeepLearning, subTitle: "Position Estimation", titleImage: Constant.DeepLearningIcon)
            ///
            Text("Real-time Prediction")
                .fontWeight(.semibold)
                .font(.caption)
            /// Chart
            Chart {
                /// IMPORTANT: We need to swap x-y to match the game map in unreal
                /// Ground Truth
                ForEach(DataManager.shared().realPosArr) { pos in
                    PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
                }.foregroundStyle(by: .value("key", Constant.GroundTruth))
                    .symbol(by: .value("key", Constant.GroundTruth))
                    .symbolSize(20)
                /// Prediction
                ForEach(dlpredictor.predTrajectory) { pos in
                    PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
                }.foregroundStyle(by: .value("key", Constant.Prediction))
                    .symbol(by: .value("key", Constant.Prediction))
                    .symbolSize(20)
                /// TX
//                ForEach(dlpredictor.dataManager.getAllTransmitterPositions()) { pos in
//                    PointMark(x: .value("x", pos.y), y: .value("y", pos.x))
//                }.foregroundStyle(by: .value("key", Constant.Transmitters))
//                    .symbol(by: .value("key", Constant.Transmitters))
//                    .symbolSize(20)
                
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
            /// Probability Distribution
            PredictionPDFChartView(data: Statistics.PDF(data: dlpredictor.errs, step: 0.1, min: 0.0, max: 10.0))
            /// Cumulative Distribution
            PredictionCDFChartView(data: Statistics.CDF(data: dlpredictor.errs, step: 0.1, min: 0.0, max: 10.0))
            /// Summary
            HStack {
                if let pos = dlpredictor.predPos, let err = dlpredictor.err {
                    Text(String(format: "Estimation: x=%.2f,y=%.2f,z=%.2f", pos.x, pos.y, pos.z))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "Error: %f", err))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                } else {
                    Text("Estimation: N/A")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }.padding(.leading, 20).padding(.trailing, 20)
            Spacer()
        }
    }
}
