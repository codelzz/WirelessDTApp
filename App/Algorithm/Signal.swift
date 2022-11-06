//
//  Signal.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation

class Signal {
    static let txPower:Int = 10
    /// System Gain was apply on both transmitter side and receiver side
    static let systemGain:Int = -45
    static let pathLossExp:Double = 2.0
    /// == Math for Calculate txPower at 1 meter
    /// let mW = Signal.dBmTomW(dBm: Double(Signal.txPower)
    /// let solidAngle = 4 x Pi
    /// let txPowerAt1M = Signal.mWTodBm(mW/solidAngle)
    static var txPowerAt1M:Int { Int(Signal.mWTodBm(mW: Signal.dBmTomW(dBm: Double(Signal.txPower + Signal.systemGain)) / (4.0 * Double.pi))) }
    
    static func dBmTomW(dBm: Double) -> Double {
        return pow(10.0, dBm * 0.1)
    }
    
    static func mWTodBm(mW: Double) -> Double {
        return 10.0 * log10(mW)
    }
    
    static func rssiToDistance(rssi: Int) -> Double {
        /// == Math
        /// diff = rssi - txPowerAt1M
        /// distance = pow(10, diff / (10 x PLE))
        let diff:Double = Double(Signal.txPowerAt1M - rssi)
        /// print(Signal.txPowerAt1M, rssi)
        return pow(10.0, diff * 0.1 / Signal.pathLossExp)
    }
}
