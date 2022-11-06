//
//  Position.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

struct Position : Identifiable, Equatable {
    let id = UUID()
    let x:Double
    let y:Double
    let z:Double
    let t:Double
    
    init(x: Double, y: Double, z: Double, t: Double = Date().timeIntervalSince1970) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
    
    init() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
        self.t = Date().timeIntervalSince1970
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

