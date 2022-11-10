//
//  DeepPos.swift
//  App
//
//  Created by x on 9/11/2022.
//

import Foundation
import CoreML

class DeepPos {
    let batch:NSNumber = 1
    let seq:NSNumber = 50
    let dim:NSNumber = 25
    var inputShape:[NSNumber] {[self.batch, self.seq, self.dim]}
    var model:rnnpos
    
    init () {
        guard let model = try? rnnpos() else {
            fatalError("Unable to load model")
        }
        self.model = model
    }
    
    func predict() -> Position? {
        
        
        guard let arr = DeepProcessor.shared().getInput(shape: [self.batch.intValue, self.seq.intValue, self.dim.intValue]) else {
            return nil
        }
        let tensor = self.convert(from: arr)
        do {
            let output = try self.model.prediction(lstm_2_input: tensor)
            let prediction = output.Identity
            let lastSeqIndex = NSNumber(value: self.seq.intValue - 1)
            let meanstd = DeepProcessor.shared().meanstd
            let x = prediction[[0, lastSeqIndex, 0]].doubleValue * (meanstd["x"]!.std + 1e-10) + meanstd["x"]!.mean
            let y = prediction[[0, lastSeqIndex, 1]].doubleValue * (meanstd["y"]!.std + 1e-10) + meanstd["y"]!.mean
            let z = prediction[[0, lastSeqIndex, 2]].doubleValue * (meanstd["z"]!.std + 1e-10) + meanstd["z"]!.mean
            return Position(x: x, y:y, z:z)
        } catch {
            print(error)
        }
        return nil
    }
    
    func convert(from: [[[Double]]]) -> MLMultiArray {
        guard let tensor = try? MLMultiArray(shape: self.inputShape, dataType: .float32) else {
            fatalError("Could not create tensorInput")
        }
        for i in 0 ..< self.batch.intValue {
            for j in 0 ..< self.seq.intValue {
                for k in 0 ..< self.dim.intValue {
                    let index:[NSNumber] = [NSNumber(value: i),NSNumber(value: j),NSNumber(value: k)]
                    tensor[index] = NSNumber(value: from[i][j][k])
                }
            }
        }
        return tensor
    }
}
