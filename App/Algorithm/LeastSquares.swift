//
//  LeastSquares.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation
import simd

class LeastSquares {
    /// Fit
    /// =====================
    /// Returns result of least squares estimation
    ///
    /// - parameters:
    ///   - distance: the distance from transmitter to receiver
    ///   - points: the position of corresponding transitter position
    /// - returns: x coordinate, y coordinate, accuracy
    static func fit(distances: [Double], points: [[Double]]) -> (Mat?, Double) {
        /// Get Matrix A
        let A = Mat(matrix: [[2 * (points[0][0] - points[2][0]), 2 * (points[0][1] - points[2][1])],
                             [2 * (points[1][0] - points[2][0]), 2 * (points[1][1] - points[2][1])]])
        /// Get Matrix B
        let B = Mat(matrix: [
            [pow(points[0][0], 2) - pow(points[2][0], 2) + pow(points[0][1], 2) - pow(points[2][1], 2) + pow(distances[2], 2) - pow(distances[0], 2)],
            [pow(points[1][0], 2) - pow(points[2][0], 2) + pow(points[1][1], 2) - pow(points[2][1], 2) + pow(distances[2], 2) - pow(distances[1], 2)]])
        /// Get the product of (matrix A) and (The transpose of matrix A, which is matrix A2 )
        if (A.T * A).det == nil {
            return (nil, Double.infinity)
        }
        let m = ((A.T * A).inv * A.T * B).T
        /// Use mean square error to esitmate accuracy
        var accuracy: Double = 0.0
        for i in 0...2 {
            let d = sqrt(pow(m[0, 0] - points[i][0], 2) + pow(m[0, 1] - points[i][1], 2))
            accuracy += pow(d - distances[i], 2)
        }
        accuracy = sqrt(accuracy) / 3.0
        return (m, Double.infinity)
    }
}
