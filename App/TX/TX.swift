//
//  TX.swift
//  App
//
//  Created by x on 3/11/2022.
//

import Foundation

struct RSSIMeasurement: Identifiable {
    var id: Double {timestamp}
    let rssi: Int
    let timestamp: Double
    
    static let example = RSSIMeasurement(rssi: -27, timestamp: 1667531183.068)
    
    public func copy() -> RSSIMeasurement {
        let copy = RSSIMeasurement(rssi: rssi, timestamp: timestamp)
        return copy
    }
}

class TX : TickableObject, Identifiable, Comparable {
    //MARK: - TX Properties
    var id: String { name }
    let name: String
    var pos:Position
    var rssi: Int?
    var timestamp: Double?
    var rssis: [RSSIMeasurement] = []
    var distance: Double { Signal.rssiToDistance(rssi: rssi!) }
    static let minRssi: Int = -255
    static let maxNumMeasurement: Int = 50
    
    //MARK: - TX Constructor
    init(name: String, position: Position) {
        self.name = name
        self.pos = position
    }
    
    //MARK: - TX Methods
    
    func update(rssi: Int, position: Position)
    {
        DispatchQueue.main.async {
            self.pos = position
            self.rssi = rssi > TX.minRssi ? rssi : nil
            self.timestamp = position.t
            /// append the measurement to the history stack
            self.rssis.append(RSSIMeasurement(rssi: rssi, timestamp: position.t))
            if self.rssis.count > TX.maxNumMeasurement
            {
                self.rssis.remove(at: 0)
            }
        }
    }
    
    func isDetectable() -> Bool {
        return self.rssi != nil && self.rssi! > TX.minRssi
    }

    //MARK: - TX Operator Method
    
    static func < (lhs: TX, rhs: TX) -> Bool {
        let lhsRSSI = lhs.rssi ?? TX.minRssi;
        let rhsRSSI = rhs.rssi ?? TX.minRssi;
        return lhsRSSI < rhsRSSI
    }
    
    static func == (lhs: TX, rhs: TX) -> Bool {
        /// ensure rssi is valid
        guard lhs.rssi != nil && rhs.rssi != nil else {
            return false
        }
        let lhsRSSI = lhs.rssi!;
        let rhsRSSI = rhs.rssi!;
        return lhsRSSI == rhsRSSI
    }
    
}
