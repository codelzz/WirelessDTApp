//
//  Predictor.swift
//  App
//
//  Created by x on 10/11/2022.
//

import Foundation

protocol PredictorProtocol {
    func predict() -> Position?
}

class Predictor : ObservableObject, PredictorProtocol {
    //MARK: Predictor Properties
    /// tick for trigger UI update from main thread
    @Published var _tick:Int = 0
    /// prediction result of the position
    var predPos:Position?
    /// ground truth of the position, this is only use for error analysis
    var realPos:Position?
    /// trajectory of the prediction i.e. the historical data of the prediction
    var predTrajectory: [Position] = []
    /// maximum length of the trajectory
    let maxPredTrajectoryLen: Int = 10
    /// prediction interval
    var minPredInterval: Double = 0.2
    /// previous predict time
    var prevPredTime: Double = Date().timeIntervalSince1970
    /// exponentially weighted moving average, ref: https://en.wikipedia.org/wiki/Moving_average
    var predMovingAvg:Position?
    var predMovingAvgTrajectory: [Position] = []
    let maxPredMovingAvgTrajectoryLen: Int = 1000
    let minPredMovingAvgTrajectoryUpdateInterval:Double = 0.5
    var movingAvgExp:Double = 0.1
    /// error
    var err: Double?
    var movingAvgErr: Double?
    var errs: [Double] = []
    let maxErrorNum: Int = 3000
    ///
    let dataManager = DataManager.shared()
    ///
    var timer:Timer?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self._didRecvDataHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
    }
    
    @objc internal func _didRecvDataHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let data = WiTracingData.make(dict: userInfo) {
                self.didRecvDataHandler(data:data)
            }
        }
    }
    
    internal func didRecvDataHandler(data: WiTracingData) {
    }
    
    @objc func timerHandler() {
        DispatchQueue.main.async {
            self.tick()
        }
    }
    
    private func tick() {
        self._tick += 1
    }

    
    //MARK: Predictor Methods
    func predict() -> Position? {
        return nil
    }
    
    func updatePredPos(position: Position) {
        if (self.predPos == position) {
            return
        }
        self.predPos = position
        self.predTrajectory.append(position)
        if self.predTrajectory.count > self.maxPredTrajectoryLen {
            self.predTrajectory.removeFirst()
        }
        self.updatePredMovingAverage(position: position)
        self.prevPredTime = Date().timeIntervalSince1970
    }
    
    func updatePredMovingAverage(position: Position) {
        if self.predMovingAvg == nil {
            self.predMovingAvg = position
        } else {
            /// calculate exponentially moving average
            let alpha = self.movingAvgExp
            let beta = 1 - self.movingAvgExp
            let movingAvg = self.predMovingAvg!
            let x = alpha * position.x + beta * movingAvg.x
            let y = alpha * position.y + beta * movingAvg.y
            let z = alpha * position.z + beta * movingAvg.z
            self.predMovingAvg = Position(x: x,  y: y, z: z, t: position.t)
        }
        
        guard self.predMovingAvgTrajectory.count == 0 || self.predMovingAvgTrajectory.last!.t + self.minPredMovingAvgTrajectoryUpdateInterval < position.t else {
            return
        }
        
        self.predMovingAvgTrajectory.append( self.predMovingAvg!)
        if self.predMovingAvgTrajectory.count > self.maxPredMovingAvgTrajectoryLen {
            self.predMovingAvgTrajectory.removeFirst()
        }
    }
    
    /// errors calculation
    func computeError(position: Position) -> Double? {
        if let realPos = self.realPos {
            /// use square error
            return Position.xyDistance(lhs: position, rhs: realPos)
        }
        return nil
    }
    
    /// updateError
    /// =============
    /// save prediction error and error histories
    func updateError() {
        guard let predPos = self.predPos else {
            return
        }
        if let e = self.computeError(position: predPos) {
            self.err = e
            self.errs.append(e)
            if self.errs.count > self.maxErrorNum {
                self.errs.remove(at: 0)
            }
        }
        guard let movingAvgPos = self.predMovingAvg else {
            return
        }
        if let e = self.computeError(position: movingAvgPos) {
            self.movingAvgErr = e
        }
    }
}
