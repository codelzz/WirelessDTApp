//
//  Predictor.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

class Predictor : ObservableObject {
    let algorithm: PositioningAlgorithm
    /// timer
    static let Interval:Double = 0.05
    var timer: Timer?
    /// data
    @Published var pos: Position?       /// pos save the prediction result
    var refPos: Position?               /// refPos the realPos collected when prediction is done, it is use for evaluate square error
    @Published var realPos: Position?   /// realPos store the latest ground truth data
    static let maxNumRealPos: Int = 100
    static let maxNumPredPos: Int = 10
    var predPoses: [Position] = []
    var realPoses: [Position] = []
    /// analysis
    var squareError: Double?
    var squareErrors: [Double] = []
    static let maxNumSquareErr: Int = 200
    
    init(algorithm: PositioningAlgorithm) {
        self.algorithm = algorithm
        /// set timer
        self.timer = Timer.scheduledTimer(timeInterval: Predictor.Interval, target: self, selector: #selector(self.predictHandler),
                                          userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRealPosHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
    }
    
    func predict(txs: [TX]) {
        if let pos = self.algorithm.predict(txs: txs) {
            if self.algorithm.isValid {
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
            if let x = userInfo["x"] as? Double, let y = userInfo["y"] as? Double, let z = userInfo["z"] as? Double {
                let pos = Position(x: x / 100.0, y: y / 100.0, z: z / 100.0)
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


