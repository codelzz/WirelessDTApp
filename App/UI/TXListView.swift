//
//  TXListView.swift
//  App
//
//  Created by x on 3/11/2022.
//

import SwiftUI
import Charts

struct TXListView: View {
//    @StateObject var txManager: TXManager = TXManager.shared()
    @StateObject var manager = DataManager.shared()
    
    var body: some View {
        VStack {
            HeaderView(title: Constant.Transmitters, subTitle: "Wireless TXs", titleImage: Constant.TXIcon)
            // List
            if self.manager.txs.count <= 0 {
                Spacer()
                Text("No Data").foregroundColor(.secondary).font(.largeTitle)
            } else {
                List {
                    /// display all tx
                    ForEach(self.manager.txs.sortByName()) { tx in
                        TXListItemView(tx: tx)
                    }
                }
            }
            Spacer()
        }
    }
}

