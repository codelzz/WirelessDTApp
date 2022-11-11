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
class DataManager : TickableObject {
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
    static let maxRealPosArrLen:Int = 50
    /// the minimun real position update interval
    static let minRealPosUpdateInterval:Double = 0.15
    //
    var timer:Timer?
    /// the observation of transmitter, key: the name of transmitter, value: the transmitter
    var transmitters:[String: TX] = [:]
    
    
    //MARK: - DataManager Constructor
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecvDataHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
        print("[INF] \(String(describing: DataManager.self)) Ready")
    }
    
    //MARK: - DataManager Handler
    @objc func didRecvDataHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let data = WiTracingData.make(dict: userInfo) {
                DispatchQueue.main.async {
                    self.updateRealPosition(position: data.rxPosition())
                    self.updateTransmitters(name: data.txname, rssi: data.rssi, position: data.txPosition())
                    
                }
            }
        }
    }
        
    @objc func timerHandler() {
        DispatchQueue.main.async {
            for (_, v) in self.transmitters {
                v.tick()
            }
            self.tick()
        }
    }
    
    //MARK: - DataManager Methods
    
    //MARK: Real Position Methods
    /// updateRealPosition
    /// ==================
    /// Asynchronously update real position
    private func updateRealPosition(position: Position) {
        /// ensure real pos position has not been initialize or the real position is out of date
        guard self.realPos == nil || self.realPos!.t + DataManager.minRealPosUpdateInterval < position.t else {
            return
        }
        self.realPos = position
        self.realPosArr.append(position)
        if self.realPosArr.count > DataManager.maxRealPosArrLen {
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
    private func updateTransmitters(name:String, rssi:Int, position:Position) {
        if self.transmitters[name] == nil {
            self.transmitters[name] = TX(name: name, position: position)
        }
        self.transmitters[name]?.update(rssi: rssi, position: position)
    }
    
//    /// getAllDetectableTransmitters
//    /// =================
//    /// get all detectable transmitters
//    func getAllDetectableTransmitters() -> [TX] {
//        var transmitters: [TX] = []
//        for (_, tx) in DataManager.shared().transmitters {
//            if tx.isDetectable() {
//                transmitters.append(tx)
//            }
//        }
//        return transmitters
//    }
//    
    func getAllTransmitterPositions() -> [Position] {
        return self.transmitters.map { $0.value.pos }
    }
}
