//
//  PredictionView.swift
//  App
//
//  Created by x on 5/11/2022.
//

import SwiftUI
import Charts

struct PredictionView: View {
    @EnvironmentObject var triPredictor:TrilaterationPredictor
    var body: some View {
        VStack{
            /// Header
            HeaderView(title: Constant.Prediction, subTitle: "Position Estimation", titleImage: Constant.PredictionIcon)
            PredictionResultChartView()
            /// Probability Distribution
            PredictionPDFChartView(data: Statistics.PDF(data: triPredictor.errs, step: 0.1, min: 0.0, max: 10.0))
            /// Cumulative Distribution
            PredictionCDFChartView(data: Statistics.CDF(data: triPredictor.errs, step: 0.1, min: 0.0, max: 10.0))
            /// Summary
            HStack {
                if let pos = triPredictor.predPos, let err = triPredictor.err {
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

