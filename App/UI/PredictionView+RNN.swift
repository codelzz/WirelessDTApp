//
//  DeepLearningView.swift
//  App
//
//  Created by x on 8/11/2022.
//

import SwiftUI
import Charts

struct DeepLearningView: View {
    @EnvironmentObject var predictor:RNNPredictor

    var body: some View {
        VStack{
            /// Header
            HeaderView(title: Constant.RNN, subTitle: "Recurrent Neural Network", titleImage: Constant.DeepLearningIcon)
            PredictionResultChartView(trajectory: predictor.predTrajectory,
                                      movingAverageTrajectory: predictor.predMovingAvgTrajectory)
            /// Probability Distribution
            PredictionPDFChartView(data: Statistics.PDF(data: predictor.errs, step: 0.1, min: 0.0, max: 10.0), movingAvgErr: nil)
            /// Cumulative Distribution
            PredictionCDFChartView(data: Statistics.CDF(data: predictor.errs, step: 0.1, min: 0.0, max: 10.0))
            /// Summary
            HStack {
                if let pos = predictor.predPos, let err = predictor.err {
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
