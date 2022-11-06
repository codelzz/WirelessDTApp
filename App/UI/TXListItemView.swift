//
//  TXListItemView.swift
//  App
//
//  Created by x on 4/11/2022.
//

import SwiftUI
import Charts

struct TXListItemView: View {
    @ObservedObject var tx: TX
    static let minDisplayRssi : Int = -100
    static let maxDisplayRssi : Int = 0
    
    var body: some View {
        let isDetectable: Bool = tx.isDetectable()
        VStack {
            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .imageScale(.medium)
                            .foregroundColor(isDetectable ? .accentColor : .secondary)
                        Text(tx.info.name)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.5)
                        Text(String(format: "x=%.2f y=%.2f z=%.2f", tx.info.x, tx.info.y, tx.info.z))
                            .font(.footnote)
                            .fontWeight(.thin)
                            .foregroundColor(.secondary)
                    }
                    
                }
                Spacer()
                Text(isDetectable ? String(format: "%.2f", Signal.rssiToDistance(rssi: tx.rssi!)) : "N/A")
                    .font(.title2)
                    .fontWeight(isDetectable ? .bold : .thin)
                    .foregroundColor(isDetectable ? .accentColor : .secondary)
                    .padding(.trailing, -5)
                Text(isDetectable ? String(format: "m", Signal.rssiToDistance(rssi: tx.rssi!)) : "")
                    .font(.body)
                    .fontWeight(.thin)
                    .foregroundColor(.secondary)
            }.padding(.bottom, -5)
            if isDetectable {
                Chart {
                    ForEach(Array(tx.rssis.enumerated()), id: \.offset) { index, element in
                        BarMark (
                            x: .value("Timestamp", index),
                            yStart: .value("RSSI", element.rssi > TX.minRssi ? element.rssi : TXListItemView.minDisplayRssi),
                            yEnd: .value("RSSI", TXListItemView.minDisplayRssi),
                            width: .fixed(5)
                        )
                    }
                }.frame(height: 20)
                    .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: TX.maxNumMeasurement)))
                    .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: TXListItemView.minDisplayRssi, upper: TXListItemView.maxDisplayRssi)))
                    .chartXAxis {}
                    .chartYAxis {}
            }
        }
    }
}
