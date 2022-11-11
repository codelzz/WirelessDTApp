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
    let maxPredTrajectoryLen: Int = 20
    /// prediction interval
    var minPredInterval: Double = 0.2
    /// previous predict time
    var prevPredTime: Double = Date().timeIntervalSince1970
    /// error
    var err: Double?
    var errs: [Double] = []
    let maxErrorNum: Int = 1000
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
                //MARK: put prediction task to background thread
        DispatchQueue.main.async {
            guard Date().timeIntervalSince1970 - self.prevPredTime > self.minPredInterval else {
                return
            }
            if let _ = self.predict() {
                self.realPos = data.rxPosition()
                self.updateError()
            }
        }
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
        self.predPos = position
        self.predTrajectory.append(position)
        if self.predTrajectory.count > self.maxPredTrajectoryLen {
            self.predTrajectory.removeFirst()
        }
        self.prevPredTime = Date().timeIntervalSince1970
    }
    
    /// errors calculation
    func computeError() -> Double? {
        if let predPos = self.predPos, let realPos = self.realPos {
            /// use square error
            return Position.xyDistance(lhs: predPos, rhs: realPos)
        }
        return nil
    }
    
    /// updateError
    /// =============
    /// save prediction error and error histories
    func updateError() {
        if let e = self.computeError() {
            self.err = e
            self.errs.append(e)
            if self.errs.count > self.maxErrorNum {
                self.errs.remove(at: 0)
            }
        }
    }
}
