//
//  Predictor.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation
import Surge

class Predictor : ObservableObject {
    let algorithm: PositioningAlgorithm
    var kalmanFilter: KalmanFilter?
    /// timer
    static let Interval:Double = 0.05
    var timer: Timer?
    /// data
    @Published var pos: Position?       /// pos save the prediction result
    var refPos: Position?               /// refPos the realPos collected when prediction is done, it is use for evaluate square error
    @Published var realPos: Position?   /// realPos store the latest ground truth data
    static let maxNumRealPos: Int = 50
    static let maxNumPredPos: Int = 30
    var realPoses: [Position] = []
    var predPoses: [Position] = []
    static let minRealPosUpdateInterval: Double = 0.15
    /// analysis
    var squareError: Double?
    var squareErrors: [Double] = []
    static let maxNumSquareErr: Int = 1000
    
    init(algorithm: PositioningAlgorithm) {
        self.algorithm = algorithm
        /// set timer
        self.timer = Timer.scheduledTimer(timeInterval: Predictor.Interval, target: self, selector: #selector(self.predictHandler),
                                          userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRealPosHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
        print("[INF] Predictor Ready")
    }
    
    func predict(txs: [TX]) {
        if let pos = self.algorithm.predict(txs: txs) {
            if self.algorithm.isValid {
                /// apply kalman filter
//                if self.kalmanFilter == nil {
//                    /// ISSUE: this pos might contain in correct timestamp
//                    self.kalmanFilter = KalmanFilter(pos: pos)
//                } else {
//                    if let pos = self.kalmanFilter?.predict(pos: pos) {
//                        self.updatePredPos(pos: pos)
//                        return
//                    }
//                }
                self.updatePredPos(pos: pos)
            }
        }
    }
    
    @objc func predictHandler()
    {
        self.predict(txs: TXManager.shared().getDetectableTXs())
    }
    
    func getSquareError() -> Double? {
        if let pos = self.pos, let realPos = self.refPos {
            return Position.xyDistance(lhs: pos, rhs: realPos)
        }
        return nil
    }
    /// Update the prediction position
    func updatePredPos(pos: Position) {
        if let prevPos = self.pos {
            if pos == prevPos {
                return
            }
        }
        self.pos = pos
        self.predPoses.append(pos)
        if self.predPoses.count > Predictor.maxNumPredPos {
            self.predPoses.remove(at: 0)
        }
        self.refPos = self.realPos
        self.updateSquareError()
    }
    /// Update the gound truth position
    func updateRealPos(pos: Position) {
        if let realPos = self.realPos {
            /// limit the update frequency for ground true
            if pos.t - realPos.t < Predictor.minRealPosUpdateInterval {
                return
            }
        }
        
        self.realPos = pos
        self.realPoses.append(pos)
        if self.realPoses.count > Predictor.maxNumRealPos {
            self.realPoses.remove(at: 0)
        }
    }
    /// Update the square error
    func updateSquareError() {
        if let error = self.getSquareError() {
            self.squareError = error
            self.squareErrors.append(error)
            if self.squareErrors.count > Predictor.maxNumSquareErr {
                self.squareErrors.remove(at: 0)
            }
        }
    }
    
    /// Notification
    @objc private func updateRealPosHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let x = userInfo["x"] as? Double,
                let y = userInfo["y"] as? Double,
                let z = userInfo["z"] as? Double,
                let t = userInfo["timestamp"] as? Double {
                let pos = Position(x: x, y: y, z: z, t: t)
                /// check if update is required
                var bUpdate: Bool = false
                if self.realPos == nil {
                    bUpdate = true
                } else if let prevPos = self.realPos {
                    if prevPos != pos {
                        bUpdate = true
                    }
                }
                /// update if necessary
                if bUpdate {
                    DispatchQueue.main.async {
                        self.updateRealPos(pos: pos)
                    }
                }
            }
        }
    }
}

