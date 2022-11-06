//
//  TXManager.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation
import Network

// Title: TXManager
// Description: A manager for managing transmitter status
// Style: Singleton https://cocoacasts.com/what-is-a-singleton-and-how-to-create-one-in-swift

class TXManager : ObservableObject {
    /// ----------------------------------------------
    /// singleton style
    private static var _shared: TXManager = {
        return TXManager(infoFileName: "tx_info")
    }()
    class func shared() -> TXManager {
        return self._shared
    }
    /// ----------------------------------------------
    private(set) var txs : [String: TX] = [:]
    
    /// private initializer for singleton, only class itself can create the instance
    private init(infoFileName: String) {
        /// Initialize Transmitters Dictionary
        let infos = TXManager.loadTXInfos(forResource: infoFileName)
        infos.forEach { info in
            /// IMPORTANT: we assume all tx have different name which will be used as the key for TX dictionary
            let tx = TX(info: TXInfo(id: info.id, name: info.name, x: info.x / 100.0, y: info.y / 100.0, z: info.z / 100))
            txs[tx.info.name] = tx
        }
        /// notification handler
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTXHander(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
    }
    
    private static func loadTXInfos(forResource: String) -> [TXInfo] {
        /// load TX informations from json
        let url = Bundle.main.url(forResource: forResource, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let infos = try! JSONDecoder().decode([TXInfo].self, from: data)
        return infos
    }
    
    @objc private func updateTXHander(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let txname = userInfo["txname"] as? String,
                let rssi = userInfo["rssi"] as? Int,
                let timestamp = userInfo["timestamp"] as? Int {
                self.updateTX(txname: txname, rssi: rssi, timestamp: timestamp)
            }
        }
    }
    
    func updateTX(txname: String, rssi: Int, timestamp: Int)
    {
        self.txs[txname]?.update(rssi: rssi, timestamp: timestamp)
    }
    
    func getDetectableTXs() -> [TX] {
        /// Only keep the detectable transmitters
        var detectableTXs: [TX] = []
        for (_, tx) in self.txs {
            if tx.isDetectable() {
                detectableTXs.append(tx)
            }
        }
        return detectableTXs
    }
}
