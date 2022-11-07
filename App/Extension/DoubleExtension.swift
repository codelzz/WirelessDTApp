//
//  DoubleExtension.swift
//  App
//
//  Created by x on 7/11/2022.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
