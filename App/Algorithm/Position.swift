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
    var xyz:[Double] { return [x,y,z] }
    
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
    
    static func * (lhs: Double, rhs: Position) -> Position {
        return Position(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z, t: rhs.t)
    }
}

extension Array where Element == Position {
}
