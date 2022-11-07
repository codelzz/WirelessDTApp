//
//  Trilateration.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

class Trilateration : PositioningAlgorithm {
    
    //MARK: - Trilateration properties
    static let maxSpeed: Double = 10.0 /// 5 m/s
    static let minNumMeasurement: Int = 4

    var prevPos: Position?
    var prevT: Double = NSDate().timeIntervalSince1970
    var speed: Double = 0
    var isValid: Bool { self.speed <= Trilateration.maxSpeed }
    
    //MARK: - Trilateration Methods
    
    internal func preprocess(txs: [TX]) -> ([Double], [[Double]]) {
        /// Keep the top three result
        let sortedTXs = txs.sorted { (lhs, rhs) in
            return lhs > rhs
        }
        /// Find the cloest 3 transmitter
        let top3TXs = sortedTXs[0...2]
        var distances : [Double] = []
        var points: [[Double]] = []
        top3TXs.forEach { tx in
            distances.append(tx.distance)
            points.append(tx.xy)
        }
        return (distances, points)
    }

    func predict(txs: [TX]) -> Position?
    {
        /// Ensure detectable transmitters meet the minimun number
        guard txs.count >= 3 else {
            return nil
        }
        /// Ensure system warmup properly
        guard txs[0].rssis.count > Trilateration.minNumMeasurement else {
            return nil
        }
        
        let (distances, points) = self.preprocess(txs: txs)
        /// User its position information and approximate for calculate the position
        let (result, _) = LeastSquares.fit(distances: distances, points: points)
        if let m = result {
            /// IMPORTANT: using default now as time **t** might cause divide by a very small value
            /// this will cause the velocity calculation in kalman filter has very large error
            let pos = Position(x: m[0,0], y: m[0,1], z: 0, t:self.getMeasuredTime(txs: txs))
            self.diagnosis(pos: pos)
            return pos
        }
        return nil
    }
    
    private func getMeasuredTime(txs: [TX]) -> Double {
        var t: Double = 0.0
        txs.forEach { tx in
            if let timestamp = tx.timestamp {
                t = max(t, timestamp)
            }
        }
        return t
    }
    
    private func diagnosis(pos: Position) {
        let now = NSDate().timeIntervalSince1970
        /// if previous position exist then calculate the speed
        if let prevPos = self.prevPos
        {
            self.speed = Position.xyDistance(lhs: prevPos, rhs: pos) / (now - self.prevT)
        }
        self.prevT = now
        self.prevPos = pos
    }
}

class SmoothSwapTrilateration : Trilateration {
    
    //MARK: - SmoothSwapTrilateration properties
    var prevTop3TXs: [TX] = []
    private let minSwapRank: Int = 5
    
    //MARK: - Trilateration Methods
    override internal func preprocess(txs: [TX]) -> ([Double], [[Double]]) {
    let top3TXs = self.smoothSwap(txs: txs)
        var distances : [Double] = []
        var points: [[Double]] = []
        top3TXs.forEach { tx in
            distances.append(tx.distance)
            points.append(tx.xy)
        }
        
        self.prevTop3TXs = Array(top3TXs)
        return (distances, points)
    }
    
    private func smoothSwap (txs: [TX]) -> [TX] {
        /// sort transmitter by rssi
        let sortedTXs = txs.sorted { (lhs, rhs) in
            return lhs > rhs
        }
        /// ensure there is sufficient valid transmitter  for swapping
        guard txs.count > self.minSwapRank else {
            return Array(sortedTXs[0...2])
        }
        /// get the tops within rank as dictionary
        let topTXs = Dictionary(uniqueKeysWithValues: Array(sortedTXs[0...self.minSwapRank]).map{($0.id, $0)})
        var newTop3TXs:[String:TX] = [:]
        
        self.prevTop3TXs.forEach { tx in
            if topTXs.contains(where: { $0.key == tx.id }) {
                newTop3TXs[tx.id] = tx
            }
        }
        
        if newTop3TXs.count == 3 {
            return Array(newTop3TXs.values)
        }
        
        for tx in sortedTXs {
            if !(newTop3TXs.contains(where: { $0.key == tx.id })) {
                newTop3TXs[tx.id] = tx
                if newTop3TXs.count >= 3 {
                    break
                }
            }
        }
        return Array(newTop3TXs.values)
    }
}
