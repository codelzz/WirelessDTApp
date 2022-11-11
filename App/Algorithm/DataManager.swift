//
//  DataManager.swift
//  App
//
//  Created by x on 10/11/2022.
//

import Foundation


// Data Manager
// ==================
// Managing Data for Prediction
class DataManager : ObservableObject {
    //MARK: - DataManager Singleton
    private static var _shared:DataManager = {
        return DataManager()
    }()
    class func shared() -> DataManager {
        return self._shared
    }
    
    //MARK: - DataManager Properties

    //MARK: Ground Truth Position Properties
    /// the latest real position
    var realPos:Position?
    /// the array contrain the historical data of real position
    var realPosArr: [Position] = []
    /// the maximun size of real position array
    let maxRealPosArrLen:Int = 50
    /// the minimun real position update interval
    let minRealPosUpdateInterval:Double = 0
    /// the observation of transmitter, key: the name of transmitter, value: the transmitter
    @Published var txs:[String: TX] = [:]
    
    //MARK: - DataManager Constructor
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecvDataHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
        print("[INF] \(String(describing: DataManager.self)) Ready")
    }
    
    //MARK: - DataManager Handler
    @objc func didRecvDataHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let data = WiTracingData.make(dict: userInfo) {
                DispatchQueue.main.async {
                    self.updateRealPosition(position: data.rxPosition())
                    self.updateTXs(name: data.txname, rssi: data.rssi, position: data.txPosition())
                }
            }
        }
    }
    
    //MARK: - DataManager Methods
    
    //MARK: Real Position Methods
    /// updateRealPosition
    /// ==================
    /// Asynchronously update real position
    private func updateRealPosition(position: Position) {
        /// ensure real pos position has not been initialize or the real position is out of date
        guard self.realPos == nil || self.realPos!.t + self.minRealPosUpdateInterval < position.t else {
            return
        }
        if let realPos = self.realPos {
            guard Position.distance(lhs: realPos,rhs: position) > 0.001 else {
                return
            }
        }
        self.realPos = position
        self.realPosArr.append(position)
        if self.realPosArr.count > self.maxRealPosArrLen {
            self.realPosArr.removeFirst()
        }
    }
    
    //MARK: Observation Methods
    /// updateTransmitter
    /// =================
    /// update observation of the transmitter
    /// - parameters:
    ///  - txname: the name of transmitter
    ///  - rssi: the signal strength measurement of transmitter from receiver position
    ///  - txPos: the position of the transmitter
    private func updateTXs(name:String, rssi:Int, position:Position) {
        if self.txs[name] == nil {
            self.txs[name] = TX(name: name, position: position)
        }
        self.txs[name]?.update(rssi: rssi, position: position)
    }
    
    func getAllTransmitterPositions() -> [Position] {
        return self.txs.map { $0.value.position }
    }
}
