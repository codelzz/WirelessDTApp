//
//  PredictionView.swift
//  App
//
//  Created by x on 5/11/2022.
//

import SwiftUI
import Charts

struct PredictionView: View {
    @EnvironmentObject var predictor:Predictor
    var body: some View {
        VStack{
            /// Header
            HeaderView(title: "Prediction", subTitle: "Position Estimation", titleImage: "target")
            PredictionResultChartView()
            /// Probability Distribution
            PredictionPDFChartView(data: Statistics.PDF(data: predictor.squareErrors, step: 0.1, min: 0.0, max: 10.0))
            /// Cumulative Distribution
            PredictionCDFChartView(data: Statistics.CDF(data: predictor.squareErrors, step: 0.1, min: 0.0, max: 10.0))
            /// Summary
            HStack {
                if let pos = predictor.pos, let err = predictor.squareError {
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

