//
//  Tensor.swift
//  App
//
//  Created by x on 9/11/2022.
//

import Foundation
import CoreML

class Tensor {
    
    let tensor:MLMultiArray
    
    init(shape: [NSNumber]) {
        guard let tensor = try? MLMultiArray(shape: shape, dataType: .float32) else {
            fatalError("Could not create tensorInput")
        }
        self.tensor = tensor
    }
        
    static func randomUniform(shape:[NSNumber]) -> MLMultiArray {
        guard var tensor = try? MLMultiArray(shape: shape, dataType: .float32) else {
            fatalError("Could not create tensorInput")
        }
        Tensor._recursiveRandomNormal(tensor: &tensor)
        return tensor
    }
    
    static private func _recursiveRandomNormal(tensor:inout MLMultiArray, indices: [NSNumber] = [], dims: Int = 1) {
        let sizeOfDim = tensor.shape[dims - 1]
        for i in 0 ..< sizeOfDim.intValue {
            let nextDims = dims + 1
            var nextIndices:[NSNumber] = indices
            nextIndices.append(NSNumber(value: i))
            if dims == tensor.shape.count {
                /// when reach at the deepest dimension, update tensor
                tensor[nextIndices] = NSNumber(value:Float32.randomNormal(mean: 0, stdDeviation: 1))
            } else {
                /// when not reach the deepest dimension, recursive call
                Tensor._recursiveRandomNormal(tensor: &tensor, indices: nextIndices, dims: nextDims)
            }
        }
    }
}
