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
    let timestamp: Double
    
    // static keywork make it exist only once and share between all struct
    static let example = WiTracingData(txname: "tx0", rxname: "rx0", x: 82.52, y: 381.23, z: 212.82, rssi: -75, timestamp: 1667531183068)
    
    //MARK: - WiTracingData Methods
    
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
    
    /// toAppUnit
    /// ==========================
    /// convert unit to match the unit using in the App
    func toAppUnit() -> WiTracingData {
        return WiTracingData(txname: self.txname,
                             rxname: self.rxname,
                             x: self.x * 0.01, /// from meter to centimeter
                             y: self.y * 0.01, /// from meter to centimeter
                             z: self.z * 0.01, /// from meter to centimeter
                             rssi: self.rssi,
                             timestamp: self.timestamp * 0.001) /// from millisecond to second
    }
}
