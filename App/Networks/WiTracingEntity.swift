//
//  WiTracingEntity.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

struct WiTracingData: Decodable {
    let txname: String
    let rxname: String
    let x: Double
    let y: Double
    let z: Double
    let rssi: Int
    let timestamp: Int
    
    // static keywork make it exist only once and share between all struct
    static let example = WiTracingData(txname: "tx0", rxname: "rx0", x: 82.52, y: 381.23, z: 212.82, rssi: -75, timestamp: 1667531183068)
    
    func toDict() -> [String: Any] {
        return [
            "txname": txname,
            "rxname": rxname,
            "x": x,
            "y": y,
            "z": z,
            "rssi": rssi,
            "timestamp": timestamp,
        ]
    }
}
