//
//  TrilaterationPredictor.swift
//  App
//
//  Created by x on 10/11/2022.
//

import Foundation


class TrilaterationPredictor: Predictor {
    let trilateration:Trilateration = SmoothSwapTrilateration()    
    var kalman:KalmanFilter?
    var enableKalman:Bool = true

    //MARK: TrilaterationPredictor Properties
    /// the observation of transmitter, key: the name of transmitter, value: the transmitter
    var txs:[String: TX] = [:]
    
    override init() {
        super.init()
        self.movingAvgExp = 0.2
    }
    
    override internal func didRecvDataHandler(data: WiTracingData) {
        //MARK: Dispatch prediction in background thread
        DispatchQueue.global(qos: .background).sync {
            self.updateTXs(name: data.txname, rssi: data.rssi, position: data.txPosition())
            /// ensure prediction is excced the minimal prediction interval
            guard Date().timeIntervalSince1970 - self.prevPredTime > self.minPredInterval else {
                return
            }
            if let prediction = self.predict() {
                /// ensure new prediction is different from the previous one
                if let prevPos = self.predPos {
                    guard Position.distance(lhs: prevPos, rhs: prediction) > 0.1 else {
                        return
                    }
                }
                
                //MARK: Dispatch result update in main thread
                //MARK: This part need to use sync to guarantee the correct update order when using Kalman Filter
                DispatchQueue.main.sync {
                    self.realPos = data.rxPosition()
                    self.updatePredPos(position: prediction)
                    self.updateError()
                }
            }
        }
    }
    
    override func predict() -> Position? {
        if let prediction = self.trilateration.predict(txs:Array(self.txs.values)) {
            if self.trilateration.isValid {
                if enableKalman {
                    /// apply kalman filter
                    if self.kalman == nil {
                        self.kalman = KalmanFilter(pos: prediction)
                    } else {
                        if let prediction = self.kalman?.predict(position: prediction) {
                            return prediction
                        }
                    }
                }
                return prediction
            }
        }
        return nil
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
}
