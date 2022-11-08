//
//  Position.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

struct Position : Identifiable, Equatable {
    //MARK: - Position Properties
    let id = UUID()
    var x:Double
    var y:Double
    var z:Double
    var t:Double
    var xy: [Double] { [self.x, self.y] }
    var yx: [Double] { [self.y, self.x] }
    var xz: [Double] { [self.x, self.z] }
    var zx: [Double] { [self.z, self.x] }
    var yz: [Double] { [self.y, self.z] }
    var zy: [Double] { [self.z, self.y] }
    var xyz: [Double] { [self.x, self.y, self.z]}

    
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, t: Double = Date().timeIntervalSince1970) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
    
    static let example: Position = Position(x: 0, y: 0, z: 0, t:0)
    
    static func distance(lhs: Position, rhs: Position) -> Double
    {
        return sqrt(pow(lhs.x - rhs.x, 2) + pow(lhs.y - rhs.y, 2) + pow(lhs.z - rhs.z, 2))
    }
    
    static func xyDistance(lhs: Position, rhs: Position) -> Double
    {
        return sqrt(pow(lhs.x - rhs.x, 2) + pow(lhs.y - rhs.y, 2))
    }
    
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

/// The protocol for prediction position
protocol PositioningAlgorithm {
    var isValid: Bool {get}
    func predict(txs: [TX]) -> Position?
}

