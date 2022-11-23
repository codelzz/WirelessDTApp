//
//  RNNPredictor.swift
//  App
//
//  Created by x on 10/11/2022.
//

import Foundation
import CoreML

struct MeanStd: Decodable {
    let id:String
    let mean:Double
    let std:Double
}

class RNNPredictor: Predictor {
    //MARK: - RNNPredictor Properties
    var kalman:KalmanFilter?
    var enableKalman:Bool = false
    ///
    private let batch:NSNumber = 1
    private let seq:NSNumber = 50
    private let dim:NSNumber = 50
    var inputShape:[NSNumber] {[self.batch, self.seq, self.dim]}
    private var model:rnnpos
    private(set) var txs : [String: [Double]] = [:] /// dictionary is not threading save in make sure all access are from same thread (e.g. main)
    private var meanstd: [String:MeanStd] = [:]
    private let maxWindowSize = 50
    
    override init() {
        guard let model = try? rnnpos() else {
            fatalError("Unable to load model")
        }
        self.model = model
        super.init()
        self.load()
    }
    
    //MARK: - DeepProcessor Notification Handler
    override internal func didRecvDataHandler(data: WiTracingData) {
        DispatchQueue.global(qos: .background).sync {
            self.updateTX(txname: data.txname.lowercased(), rssi: data.rssi, timestamp: data.timestamp)
            guard Date().timeIntervalSince1970 - self.prevPredTime > self.minPredInterval else {
                return
            }
            if let prediction = self.predict() {
                DispatchQueue.main.async {
                    self.realPos = data.rxPosition()
                    self.updatePredPos(position: prediction)
                    self.updateError()
                }
            }
        }
    }
    
    
    //MARK: - DeepProcessor Methods
    override func predict() -> Position? {
        if let prediction = self._predict() {
            if enableKalman {
                /// apply kalman filter
                if self.kalman == nil {
                    self.kalman = KalmanFilter(pos: prediction)
                } else {
                    if let prediction = self.kalman?.predict(position: prediction) {
                        return prediction
                    }
                }
            }
            return prediction
        }
        return nil
    }
    
    /// update transmitter
    /// =====================
    /// update transmitter information
    func updateTX(txname: String, rssi: Int, timestamp: Double) {
        /// if transmitter already in the group
        var normRssi:Double?
        if let _ = self.txs[txname] {
            if rssi < Constant.MinRSSI {
                /// of rssi is undetactable, then use last measurement
//                normRssi = self.txs[txname]?.last
//                if let interpolation = self.meanstd[txname]?.mean {
////                    normRssi = self.normalizeRSSI(txname: txname, rssi: Int(interpolation))
//                    normRssi = 0
//                }
//                normRssi = 0
                normRssi = self.txs[txname]!.last
            } else {
                normRssi = self.normalizeRSSI(txname: txname, rssi: rssi)
            }
//            normRssi = self.normalizeRSSI(txname: txname, rssi: rssi)
            let finalRssi = normRssi ?? 0
            self.txs[txname]?.append(finalRssi)
            
            if self.txs[txname]!.count > self.maxWindowSize {
                self.txs[txname]?.remove(at: 0)
            }
        } else {
            /// if no measurement
            if rssi <= Constant.MinRSSI {
                /// of rssi is undetactable, then use last measurement
//                if let interpolation = self.meanstd[txname]?.mean {
//                    normRssi = self.normalizeRSSI(txname: txname, rssi: Int(interpolation))
//                }
                normRssi = 0
            } else {
                normRssi = self.normalizeRSSI(txname: txname, rssi: rssi)
            }
            
            let finalRssi = normRssi ?? 0

//            normRssi = self.normalizeRSSI(txname: txname, rssi: rssi)
//            if let rssi = normRssi {
            self.txs[txname] = [finalRssi]
//            }
        }
    }
    
    private func load() {
        /// load TX informations from json
        let url = Bundle.main.url(forResource: Constant.MeanStdFilename, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONDecoder().decode([MeanStd].self, from: data)
        for i in json {
            self.meanstd[i.id] = i
        }
    }
    
    /// normalize RSSI
    /// ==============
    /// normalize rssi data based on statistic of historical data
    private func normalizeRSSI(txname:String, rssi:Int) -> Double? {
        /// ensure transmitter in the historical data
        guard let stat = self.meanstd[txname] else {
            return nil
        }
        /// calculate the normalize result
        return (Double(rssi) - stat.mean) / (stat.std + 1e-10)
    }
    
    /// return the normalize tensor input
    public func getInput(shape: [Int]) -> [[[Double]]]? {
        let rank = shape.count
        /// check the rank
        guard rank == 3 else {
            return nil
        }
        let batch = shape[0]
        /// lenght of the sequence
        let seq = shape[1]
        /// dimension size of feature
        let dim = shape[2]
        /// check batch size
        guard batch == 1 else {
            return nil
        }
        /// check feature dimension
        guard dim == self.txs.count else {
            return nil
        }
        /// check sequence length for all dimension
        for (_, v) in self.txs {
            guard seq <= v.count else {
                return nil
            }
        }
        //MARK: this will make app only work if txname contain only tx and id(Int) e.g. "tx0"
        let txnames = Array(self.txs.keys).sorted { lhs, rhs in
            let lhsID:Int = Int(lhs.replacingOccurrences(of: "tx", with: ""))!
            let rhsID:Int = Int(rhs.replacingOccurrences(of: "tx", with: ""))!
            return lhsID < rhsID
        }
        /// check dimension again
        guard txnames.count == dim else {
            print("[ERR] incorrect dimension")
            return nil
        }
        
        var seqs:[[Double]] = []
        for i in 0 ..< seq {
            var dims:[Double] = []
            for txname in txnames {
                if let tx =  self.txs[txname]  {
                    let start = tx.count - seq
                    let rssi = tx[start + i]
                    dims.append(rssi)
                } else
                {
                    fatalError("key not found")
                }
                
            }
            seqs.append(dims)
        }
        return [seqs]
    }
    
    func _predict() -> Position? {
        guard let arr = self.getInput(shape: [self.batch.intValue, self.seq.intValue, self.dim.intValue]) else {
            return nil
        }
        let tensor = self.convert(from: arr)
        do {
            let output = try self.model.prediction(lstm_29_input: tensor)
            let prediction = output.Identity
            let lastSeqIndex = NSNumber(value: self.seq.intValue - 1)
            let meanstd = self.meanstd
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
