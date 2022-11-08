//
//  LeastSquaresApproximations.swift
//  App
//
//  Created by x on 8/11/2022.
//
// ref: https://www.youtube.com/watch?v=AmQcoopBUTk&ab_channel=MITOpenCourseWare
// ref: https://www.youtube.com/watch?v=o0N5VVX6K9Y&ab_channel=KimberlyBrehm

import Foundation
import Surge

//MARK: - Least Squares Approximation for Solving Positioning Problem

/**
 Problem Statement:
    Assuming we received measurement from three different transmitter TX1, TX2, TX3 with positions and distance approximations:
        
        --------------------------------------------------
        Transmitters |  Position  | Distance Approximation
        --------------------------------------------------
                 TX1 | x1, y1, z1 |  d1
                 TX2 | x2, y2, z2 |  d2
                 TX3 | x3, y3, z3 |  d3
        --------------------------------------------------
 
    We want to estimate the receiver postion RX (x, y, z), by minimizing the distance error:
    
        (x - x1)^2 + (y - y1)^2 + (z - z1)^2  = d1^2
        (x - x2)^2 + (y - y2)^2 + (z - z3)^2  = d2^2
        (x - x3)^2 + (y - y2)^2 + (z - z3)^2  = d3^2
 
    which and be expand to
 
        x^2 + x1^2 - 2x1x + y^2 + y1^2 - 2y1y + z^2 + z1^2 - 2z1z = d1^2    eq.1
        x^2 + x2^2 - 2x2x + y^2 + y2^2 - 2y2y + z^2 + z2^2 - 2z2z = d2^2    eq.2
        x^2 + x3^2 - 2x3x + y^2 + y3^2 - 2y3y + z^2 + z3^2 - 2z3z = d3^2    eq.3
 
    then, we can eliminate the x^2, y^2, z^2 by subtract the equations
        
        eq.1 - eq.2 | x1^2 - x2^2 - 2x1x + 2x2x + y1^2 - y2^2 - 2y1y + 2y2y + z1^2 - z2^2 - 2z1z + 2z2z = d1^2 - d2^2
        eq.1 - eq.3 | x1^2 - x3^2 - 2x1x + 2x3x + y1^2 - y3^2 - 2y1y + 2y3y + z1^2 - z3^2 - 2z1z + 2z3z = d1^2 - d3^2
        
    then
 
        eq.1 - eq.2 | 2x2x - 2x1x + 2y2y - 2y1y + 2z2z - 2z1z = d1^2 - d2^2 + x2^2 - x1^2 + y2^2 - y1^2 + z2^2 - z1^2
        eq.1 - eq.3 | 2x3x - 2x1x + 2y3y - 2y1y + 2z3z - 2z1z = d1^2 - d3^2 + x3^2 - x1^2 + y3^2 - y1^2 + z3^2 - z1^2
  
    then

        eq.1 - eq.2 | 2x2x - 2x1x + 2y2y - 2y1y + 2z2z - 2z1z = d1^2 - x1^2 - y1^2 - z1^2 - d2^2 + x2^2 + y2^2 + z2^2
        eq.1 - eq.3 | 2x3x - 2x1x + 2y3y - 2y1y + 2z3z - 2z1z =
 
    hence we can reorganize the equation as linear algeber  equation

 
                    A                        x                          b
        | 2(x2-x1)  2(y2-y1)  2(z2-z1) |   | x |     | d1^2 - x1^2 - y1^2 - z1^2 - d2^2 + x2^2 + y2^2 + z2^2 |
        | 2(x3-x1)  2(y3-y1)  2(z3-z1) |   | y |  =  | d1^2 - x1^2 - y1^2 - z1^2 - d3^2 + x3^2 + y3^2 + z3^2 |
                                           | z |
 
    then, we have
                                        Ax = b
                                       ATAx = ATb
                                (ATA)^-1ATA x =  (ATA)^-1ATb
                                         Ix = (ATA)^-1ATb
                                         x = (ATA)^-1ATb
 */

class LeastSquares {
    //MARK: - Least Squares Properties
    
    /// the average error of prediction from all points
    static let minAvgError:Double = 2.0

    
    //MARK: - Least Squares Methods
    
    /// Fitting method
    /// ===================
    ///  This method received the position of the objects and the distance estimation from them
    /// - parameters:
    ///    - points: the position of the objects
    ///    - distance: the distance from the positions
    /// - returns: the estimated observation position
    static public func fit(points: [Position], distances: [Double], dims: Int = 3 ) -> Position? {
        guard points.count > 0 && points.count == distances.count else {
            return nil
        }
        guard dims == 3 || dims == 2 else {
            return nil
        }
        
        let size = points.count
        var gridA: [Double] = []
        var gridB: [Double] = []
        let p0 = points.first!
        let d0 = distances.first!
        // c = d1^2 - x1^2 - y1^2 - z1^2
        var c0 = pow(d0,2.0) - pow(p0.x,2.0) - pow(p0.y,2.0)
        if dims == 3 {
            c0 -= pow(p0.z, 2.0)
        }
        for i in 1..<size {
            let p = points[i]
            let d = distances[i]
            var c = pow(d,2.0) - pow(p.x,2.0) - pow(p.y,2.0)
            if dims == 3 {
                c -= pow(p.z, 2.0)
            }
            // update grid
            gridA.append(p.x - p0.x)
            gridA.append(p.y - p0.y)
            if dims == 3 {
                gridA.append(p.z - p0.z)
            }
            gridB.append(c0 - c)
            
        }
        // Matrix A
        let A = 2.0 * Mat(matrix: Matrix(rows: size - 1, columns: dims, grid: gridA))
        // Matrix b
        let b = Mat(matrix: Matrix(rows: size - 1, columns: 1, grid: gridB))
        
        if let x = solve(A: A, b: b) {
            let pos = Position(x: x[0,0], y: x[0,1], z:x[0,2])
            if self.check(points: points, distances: distances, prediction: pos) {
                return pos
            }
        }
        return nil
    }
    
    static private func solve(A: Mat, b:Mat) -> Mat? {
        // ensure A is invertable
        guard (A.T * A).det != nil else {
            return nil
        }
        /// Calculate the estimation Ax = b
        return ((A.T * A).inv * A.T * b).T
    }
    
    /// Error check
    static private func check(points: [Position], distances: [Double], prediction: Position) -> Bool {
        var sum: Double = 0.0
        for i in (0 ..< points.count) {
            sum = abs(Position.distance(lhs: points[i], rhs: prediction) - distances[i])
        }
        let avg = sum / Double(points.count)
        return avg <= LeastSquares.minAvgError
    }
}
