//
//  Trilateration.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

class Trilateration {
    
    //MARK: - Trilateration properties
    static let maxSpeed: Double = 5 /// 5 m/s
    static let minNumMeasurement: Int = 4

    var prevPos: Position?
    var prevT: Double = NSDate().timeIntervalSince1970
    var speed: Double = 0
    var isValid: Bool { self.speed <= Trilateration.maxSpeed }
    
    //MARK: - Trilateration Methods
    
    internal func preprocess(txs: [TX]) -> ([Position], [Double]) {
        /// Keep the top three result
        let sortedTXs = txs.sorted { (lhs, rhs) in
            return lhs.rssi! > rhs.rssi!
        }
        var points: [Position] = []
        var distances : [Double] = []
        sortedTXs.forEach { tx in
            distances.append(tx.distance)
            points.append(tx.pos)
        }
        return (Array(points[0...3]), Array(distances[0...3]))
    }

    func predict(txs: [TX]) -> Position?
    {
        /// Ensure detectable transmitters meet the minimun number
        guard txs.count >= 4 else {
            return nil
        }
        /// Ensure system warmup properly
        guard txs[0].rssis.count > Trilateration.minNumMeasurement else {
            return nil
        }
        
        let (points, distances) = self.preprocess(txs: txs)
        if let pos = LeastSquares.fit(points: Array(points), distances: Array(distances)) {
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

class SmoothSwapTrilateration :  Trilateration{
    
    //MARK: - SmoothSwapTrilateration properties
    var prevTop4TXs: [TX] = []
    private let minSwapRank: Int = 8
    
    //MARK: - Trilateration Methods
    override internal func preprocess(txs: [TX]) -> ([Position], [Double]) {
        
        let tops = self.smoothSwap(txs: txs)
        var points: [Position] = []
        var distances : [Double] = []
        tops.forEach { tx in
            points.append(tx.pos)
            distances.append(tx.distance)
        }
        self.prevTop4TXs = Array(tops[0...3])
        return (points, distances)
    }
    
    private func smoothSwap (txs: [TX]) -> [TX] {
        /// sort transmitter by rssi
        let sortedTXs = txs.sorted { (lhs, rhs) in
            return lhs > rhs
        }
        
        /// ensure there is sufficient valid transmitter  for swapping
        guard txs.count > self.minSwapRank else {
            return Array(sortedTXs[0 ... 3])
        }
        /// get the tops within rank as dictionary
        let topTXs = Dictionary(uniqueKeysWithValues: Array(sortedTXs[0...self.minSwapRank]).map{($0.id, $0)})
        var newTop4TXs:[String:TX] = [:]
        
        self.prevTop4TXs.forEach { tx in
            if topTXs.contains(where: { $0.key == tx.id }) {
                newTop4TXs[tx.id] = tx
            }
        }
        
        if newTop4TXs.count == 4 {
            return Array(newTop4TXs.values)
        }
        
        for tx in sortedTXs {
            if !(newTop4TXs.contains(where: { $0.key == tx.id })) {
                newTop4TXs[tx.id] = tx
                if newTop4TXs.count >= 4 {
                    break
                }
            }
        }
        return Array(newTop4TXs.values)
    }
}
