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
            Text("Real-time Prediction")
                .fontWeight(.semibold)
            PredictionResultChartView()
            /// Square Error Histogram
            Text("Square Error Histogram")
                .fontWeight(.semibold)
            PredictionSqureErrorChartView(data: Histogram.generate(data: predictor.squareErrors, bins: 100, min: 0, max: 6))
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

