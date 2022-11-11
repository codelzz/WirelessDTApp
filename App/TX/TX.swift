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

class TX : ObservableObject, Identifiable {
    //MARK: - TX Properties
    var id: String { name }
    let name: String
    var position:Position
    var x: Double { position.x }
    var y: Double { position.y }
    var z: Double { position.z }
    var timestamp: Double {position.t}
    @Published var rssi: Int?
    var rssis: [RSSIMeasurement] = []
    var distance: Double { Signal.rssiToDistance(rssi: rssi!) }
    static let minRssi: Int = -255
    static let maxRssisNum: Int = 50
    
    //MARK: - TX Constructor
    init(name: String, position: Position) {
        self.name = name
        self.position = position
    }
    
    //MARK: - TX Methods
    func update(rssi: Int, position: Position)
    {
        self.position = position
        self.rssi = rssi > TX.minRssi ? rssi : nil
        /// append the measurement to the history stack
        self.rssis.append(RSSIMeasurement(rssi: rssi, timestamp: position.t))
        if self.rssis.count > TX.maxRssisNum {
            self.rssis.remove(at: 0)
        }
    }
    
    func isDetectable() -> Bool {
        return self.rssi != nil && self.rssi! > TX.minRssi
    }
    
    func duplicate() -> TX {
        let tx = TX(name: self.name, position: self.position)
        tx.rssi = self.rssi
        tx.rssis = self.rssis
        return tx
    }
}

//MARK: - TX Array Extension
extension Array where Element == TX {
    func sortByName() -> [TX] {
        return self.sorted { lhs, rhs in
            if let lhsID = Int(lhs.name.replacingOccurrences(of: "tx", with: "")) {
                if let rhsID:Int = Int(rhs.name.replacingOccurrences(of: "tx", with: "")) {
                    return lhsID < rhsID
                }
            }
            return false
        }
    }
    
    /// getAllDetectableTransmitters
    /// =================
    /// get all detectable transmitters
    func getAllDetectable() -> [TX] {
        var txs: [TX] = []
        self.forEach { tx in
            if tx.isDetectable() {
                txs.append(tx)
            }
        }
        return txs
    }
    
    func getAllPositions() -> [Position] {
        return self.map { $0.position }
    }
    
    func duplicate() -> [TX] {
        var txs: [TX] = []
        self.forEach { tx in
            txs.append(tx.duplicate())
        }
        return txs
    }
}

//MARK: - TX Dictionary Extension
extension Dictionary where Key == String, Value == TX {
    func sortByName() -> [TX] {
        return Array(self.values).sortByName()
    }
    
    func getAllDetectable() -> [TX] {
        return Array(self.values).getAllDetectable()
    }
    
    func getAllPositions() -> [Position] {
        return Array(self.values).getAllPositions()
    }
}
