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
    var transmitters:[String: TX] = [:]
    
    override init() {
        super.init()
    }
    
    override internal func didRecvDataHandler(data: WiTracingData) {
        DispatchQueue.main.async {
            self.updateTransmitters(name: data.txname, rssi: data.rssi, position: data.txPosition())
            guard Date().timeIntervalSince1970 - self.prevPredTime > self.minPredInterval else {
                return
            }
            if let _ = self.predict() {
                self.realPos = data.rxPosition()
                self.updateError()
            }
        }
    }
    
    override func predict() -> Position? {
        let transmitters = self.getAllDetectableTransmitters()
        if let prediction = self.trilateration.predict(txs: transmitters) {
            if self.trilateration.isValid {
                if enableKalman {
                    /// apply kalman filter
                    if self.kalman == nil {
                        self.kalman = KalmanFilter(pos: prediction)
                    } else {
                        if let prediction = self.kalman?.predict(position: prediction) {
                            self.updatePredPos(position: prediction)
                            return prediction
                        }
                    }
                }
                self.updatePredPos(position: prediction)
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
    private func updateTransmitters(name:String, rssi:Int, position:Position) {
        if self.transmitters[name] == nil {
            self.transmitters[name] = TX(name: name, position: position)
        }
        self.transmitters[name]?.update(rssi: rssi, position: position)
    }

    /// getAllDetectableTransmitters
    /// =================
    /// get all detectable transmitters
    func getAllDetectableTransmitters() -> [TX] {
        var transmitters: [TX] = []
        for (_, tx) in self.transmitters {
            if tx.isDetectable() {
                transmitters.append(tx)
            }
        }
        return transmitters
    }

    func getAllTransmitterPositions() -> [Position] {
        return self.transmitters.map { $0.value.pos }
    }
}
