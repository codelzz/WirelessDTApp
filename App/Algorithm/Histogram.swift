//
//  Histogram.swift
//  App
//
//  Created by x on 6/11/2022.
//

import Foundation

class Histogram {
    static func generate(data: [Double], bins: Int, min: Double? = nil, max:Double? = nil) -> [[Double]]? {
        guard bins > 0 && data.count > 1 else {
            return nil
        }
        
        var _min = data.min()
        var _max = data.max()
        
        if min != nil {
            _min = min
        }
        if max != nil {
            _max = max
        }
        
        if let max = _max, let min = _min {
            
            let unit = (max - min) / Double(bins)
            var counter: [Double: Double] = [:]
            
            let origin = min + 0.5 * unit
            for i in (0..<bins) {
                let x = origin + Double(i) * unit
                counter[x] = 0
            }
            
            data.forEach { v in
                if v > max {
                    let x = min + (Double(bins) - 0.5) * unit
                    if let _ = counter[x] {
                        counter[x]! += 1
                    }
                }
                else
                {
                    for i in (1...bins) {
                        /// find the bin
                        var x = min + Double(i) * unit
                        if v <= x {
                            x -= 0.5 * unit
                            if let _ = counter[x] {
                                counter[x]! += 1
                            }
                            break
                        }
                    }
                }
            }
            
            var histData: [[Double]] = []
            counter.forEach { (k, v) in
                histData.append([k, Double(v) / Double(data.count)])
            }
            return histData.sorted(by: {$0[0] > $1[0]})
        }
        return nil
    }
}
