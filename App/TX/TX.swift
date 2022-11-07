//
//  TX.swift
//  App
//
//  Created by x on 3/11/2022.
//

import Foundation

struct TXInfo: Decodable, Identifiable {
    let id: Int
    let name: String
    let x: Double
    let y: Double
    let z: Double
    
    // static keywork make it exist only once and share between all struct
    static let example = TXInfo(id: 0, name: "TX0", x: 100.0, y: 0.0, z: -100.0)
}

struct RSSIMeasurement: Identifiable {
    var id: Double {timestamp}
    let rssi: Int
    let timestamp: Double
    
    static let example = RSSIMeasurement(rssi: -27, timestamp: 1667531183.068)
}

class TX : ObservableObject, Identifiable, Comparable {
    var id: String { info.name }
    let info: TXInfo
    @Published var rssi: Int?
    var timestamp: Double?
    var rssis: [RSSIMeasurement] = []
    var distance: Double { Signal.rssiToDistance(rssi: rssi!) }
    static let minRssi: Int = -255
    static let maxNumMeasurement: Int = 50

    /// Coodinates
    var xy: [Double] { [self.info.x, self.info.y] }
    
    init(info: TXInfo) {
        self.info = info
    }
    
    func update(rssi: Int, timestamp: Double)
    {
        DispatchQueue.main.async {
            self.rssi = rssi > TX.minRssi ? rssi : nil
            self.timestamp = timestamp
            /// append the measurement to the history stack
            self.rssis.append(RSSIMeasurement(rssi: rssi, timestamp: timestamp))
            if self.rssis.count > TX.maxNumMeasurement
            {
                self.rssis.remove(at: 0)
            }
        }
    }
    
    func isDetectable() -> Bool {
        return self.rssi != nil && self.rssi! > TX.minRssi
    }
    
    static func < (lhs: TX, rhs: TX) -> Bool {
        let lhsRSSI = lhs.rssi ?? TX.minRssi;
        let rhsRSSI = rhs.rssi ?? TX.minRssi;
        return lhsRSSI < rhsRSSI
    }
    
    static func == (lhs: TX, rhs: TX) -> Bool {
        let lhsRSSI = lhs.rssi ?? TX.minRssi;
        let rhsRSSI = rhs.rssi ?? TX.minRssi;
        return lhsRSSI == rhsRSSI
    }
}