//
//  Histogram.swift
//  App
//
//  Created by x on 6/11/2022.
//

import Foundation

class Statistics {
    static func PDF(data: [Double], step: Double, min: Double, max:Double) -> [[Double]] {
        guard step > 0 && data.count > 1 && max > min && max - min > step else {
            return []
        }
        
        let bins = Int(((max - min) / step).rounded(.up))
        /// IMPORTANT: using string as key to prevent numerical unstable
        var counter: [String: Double] = [:]
        let origin = min + 0.5 * step
        for i in (0..<bins) {
            let x = String(format: "%f", origin + Double(i) * step)
            counter[x] = 0
        }
        data.forEach { v in
            if v >= max {
                let x = String(format: "%f", max - 0.5 * step)
                counter[x]! += 1
            } else {
                for i in (0..<bins) {
                    let x = origin + Double(i) * step
                    let lowerbound = x - 0.5 * step
                    let upperbound = x + 0.5 * step
                    if v >= lowerbound && v < upperbound
                    {
                        counter[String(format: "%f", x)]! += 1
                    }
                }
            }
        }

        var pdf: [[Double]] = []
        counter.forEach { (k, v) in
            pdf.append([(k as NSString).doubleValue, Double(v) / Double(data.count)])
        }
        return pdf.sorted(by: {$0[0] < $1[0]})
    }
    
    static func CDF(data: [Double], step: Double, min: Double, max:Double) -> [[Double]] {
        let pdf = Statistics.PDF(data: data, step: step, min: min, max: max)
        var cdf: [[Double]] = []
        var sum:Double = 0.0
        pdf.forEach { v in
            sum += v[1]
            /// IMPORTANT: prevent numerical unstable
            if sum > 1.0 {
                sum = 1.0
            }
            cdf.append([v[0], sum])
        }
        return cdf
    }
}
