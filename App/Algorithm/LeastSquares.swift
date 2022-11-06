//
//  LeastSquares.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation
import simd

class LeastSquares {
    static func fit(distances: [Double], points: [[Double]]) -> (simd_double2, Double) {
        /// Get Matrix A
        let Ax = simd_double2(x: 2 * (points[0][0] - points[2][0]), y: 2 * (points[1][0] - points[2][0]))
        let Ay = simd_double2(x: 2 * (points[0][1] - points[2][1]), y: 2 * (points[1][1] - points[2][1]))
        let A = simd_double2x2([Ax, Ay])
        /// Get Matrix B
        let Bx = pow(points[0][0], 2) - pow(points[2][0], 2) + pow(points[0][1], 2) - pow(points[2][1], 2) + pow(distances[2], 2) - pow(distances[0], 2)
        let By = pow(points[1][0], 2) - pow(points[2][0], 2) + pow(points[1][1], 2) - pow(points[2][1], 2) + pow(distances[2], 2) - pow(distances[1], 2)
        let B = simd_double2(x: Bx, y: By)
        /// Transpose Matrix A
        let AT = A.transpose
        /// Get the product of (matrix a1) and (The transpose of matrix a1, which is matrix a2 )
        let m1 = simd_mul(AT, A)
        let invm1 = m1.inverse
        let m2 = simd_mul(invm1, AT)
        /// Get the product of tmpMatrix2 and matrix b1
        let result = simd_mul(m2, B)
        /// Use Mean Square Error to get accuracy
        var accuracy: Double = 0.0
        for i in 0...2 {
            let d = sqrt(pow(result[0] - points[i][0], 2) + pow(result[1] - points[i][1], 2))
            accuracy += sqrt(pow(d - distances[i], 2))
        }
        accuracy = accuracy / 3.0

        if accuracy.isNaN {
            return (simd_double2(x:0, y:0), Double.infinity)
        }
        return (result, accuracy)
    }
}
