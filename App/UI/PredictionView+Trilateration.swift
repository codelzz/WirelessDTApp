//
//  PredictionView.swift
//  App
//
//  Created by x on 5/11/2022.
//

import SwiftUI
import Charts

struct TrilaterationPredictionView: View {
    @EnvironmentObject var predictor:TrilaterationPredictor
    
    var body: some View {
        VStack{
            /// Header
            HeaderView(title: Constant.Trilateration, subTitle: "Trilateration Algorithm Evaluation", titleImage: Constant.PredictionIcon)
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

