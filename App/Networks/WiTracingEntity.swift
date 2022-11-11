//
//  WiTracingEntity.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

struct WiTracingData: Decodable {
    //MARK: - WiTracingData Properties
    
    /// transmitter information
    let txname: String
    let txx: Double
    let txy: Double
    let txz: Double
    /// receiver information --- or the ground truth position
    let rxname: String
    let rxx: Double
    let rxy: Double
    let rxz: Double
    let rssi: Int
    /// measure time
    let timestamp: Double

    // static keywork make it exist only once and share between all struct
    static let example = WiTracingData(txname: "tx0", txx: 12.0, txy: 32.0, txz: 12,
                                       rxname: "rx0", rxx: 21.0, rxy: 51.0, rxz: 32,
                                       rssi: -56, timestamp: 1667531183068)
    //MARK: - WiTracingData Methods
    /// toDict
    /// ==========================
    /// convert struct to dictionary
    /// - returns: WiTracingData
    func toDict() -> [String: Any] {
        return [
            "txname": self.txname,"txx": self.txx,"txy": self.txy,"txz": self.txz,
            "rxname": self.rxname,"rxx": self.rxx,"rxy": self.rxy,"rxz": self.rxz,
            "rssi": self.rssi,"timestamp": self.timestamp]
    }
    
    /// make
    /// ==========================
    /// create a WiTracingData based on dictionary
    /// - parameters:
    ///  - dict: the dictionary containing information of a WiTracingData
    /// - returns: WiTracingData
    static func make(dict: [AnyHashable: Any]) -> WiTracingData? {
        if let txname = dict["txname"] as? String,
           let txx = dict["txx"] as? Double,
           let txy = dict["txy"] as? Double,
           let txz = dict["txz"] as? Double,
           let rxname = dict["rxname"] as? String,
           let rxx = dict["rxx"] as? Double,
           let rxy = dict["rxy"] as? Double,
           let rxz = dict["rxz"] as? Double,
           let rssi = dict["rssi"] as? Int,
           let timestamp = dict["timestamp"] as? Double {
                return WiTracingData(txname: txname, txx: txx, txy: txy, txz: txz,
                                     rxname: rxname, rxx: rxx, rxy: rxy, rxz: rxz,
                                     rssi: rssi, timestamp: timestamp)
        }
        return nil
    }
    
    /// txPosition
    /// ==========================
    /// get transmitter position
    public func txPosition() -> Position {
        return Position(x:self.txx, y: self.txy, z: self.txz, t: self.timestamp)
    }
    
    /// rxPosition
    /// ==========================
    /// get receiver position
    public func rxPosition() -> Position {
        return Position(x:self.rxx, y: self.rxy, z: self.rxz, t: self.timestamp)
    }
    
    /// toAppUnit
    /// ==========================
    /// convert unit to match the unit using in the App
    /// - returns: WiTracingData
    func toAppUnit() -> WiTracingData {
        return WiTracingData(txname: self.txname,
                             txx: self.txx * 0.01, /// from meter to centimeter
                             txy: self.txy * 0.01, /// from meter to centimeter
                             txz: self.txz * 0.01, /// from meter to centimeter
                             rxname: self.rxname,
                             rxx: self.rxx * 0.01, /// from meter to centimeter
                             rxy: self.rxy * 0.01, /// from meter to centimeter
                             rxz: self.rxz * 0.01, /// from meter to centimeter
                             rssi: self.rssi,
                             timestamp: self.timestamp * 0.001) /// from millisecond to second
    }
}
