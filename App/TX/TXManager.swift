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
        return TXManager()
    }()
    class func shared() -> TXManager {
        return self._shared
    }
    /// ----------------------------------------------
    private(set) var txs : [String: TX] = [:]
    public var prevMeasuredTime:Double = Date().timeIntervalSince1970
    
    /// private initializer for singleton, only class itself can create the instance
    private init() {
        /// notification handler
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecvDataHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
    }
    
    @objc private func didRecvDataHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let txname = userInfo["txname"] as? String,
                let x = userInfo["txx"] as? Double,
                let y = userInfo["txy"] as? Double,
                let z = userInfo["txz"] as? Double,
                let rssi = userInfo["rssi"] as? Int,
                let timestamp = userInfo["timestamp"] as? Double {
                let pos = Position(x: x, y: y, z: z, t: timestamp)
                self.updateTX(txname: txname, rssi: rssi, timestamp: timestamp, position: pos)
                self.prevMeasuredTime = timestamp
            }
        }
    }
    
    func updateTX(txname: String, rssi: Int, timestamp: Double, position: Position? = nil) {
        if let _ = self.txs[txname] {
            self.txs[txname]?.update(rssi: rssi, timestamp: timestamp, position: position)
        } else {
            if let pos = position {
                self.txs[txname] = TX(name: txname, position: pos)
                self.txs[txname]?.update(rssi: rssi, timestamp: timestamp)
            }
        }
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
