//
//  Trilateration.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

class Trilateration : PositioningAlgorithm {
    static let maxSpeed: Double = 10 /// 5 m/s

    var prevPos: Position?
    var prevT: Double = NSDate().timeIntervalSince1970
    var speed: Double = 0
    var isValid: Bool { self.speed <= Trilateration.maxSpeed }
    
    func preprocess(txs: [TX]) -> ([Double], [[Double]]) {
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
        let (distances, points) = self.preprocess(txs: txs)
        /// User its position information and approximate for calculate the position
        let (point, _) = LeastSquares.fit(distances: distances, points: points)
        let pos: Position = Position(x: point.x, y: point.y, z: 0)
//        if accuracy > 5 {
//            return nil
//        }
        /// ignore for Zero prediction
        if pos.x == 0.0 && pos.y == 0.0 && pos.z == 0.0 {
            return nil
        }
        self.diagnosis(pos: pos)
        return pos
    }
    
    func diagnosis(pos: Position) {
        let now = NSDate().timeIntervalSince1970
        /// if previous position exist then calculate the speed
        if let prevPos = self.prevPos
        {
            /// speed = distance / time difference
            self.speed = Position.xyDistance(lhs: prevPos, rhs: pos) / (now - self.prevT)
        }
        self.prevT = now
        self.prevPos = pos
    }
}
