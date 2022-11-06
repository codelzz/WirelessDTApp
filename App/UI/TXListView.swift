//
//  TXListView.swift
//  App
//
//  Created by x on 3/11/2022.
//

import SwiftUI
import Charts

struct TXListView: View {
    @StateObject var txManager: TXManager = TXManager.shared()
    
    var body: some View {
        VStack {
            HeaderView(title: "Transmitters", subTitle: "Wireless TXs", titleImage: "antenna.radiowaves.left.and.right.circle")
            // List
            List {
                /// display all tx
                ForEach(self.txManager.txs.sorted (by: >), id: \.value.info.id) { key, tx in
                    TXListItemView(tx: tx)
                }
            }
            Spacer()
        }
    }
}

struct TXListView_Previews: PreviewProvider {
    static var previews: some View {
        TXListView()
    }
}

