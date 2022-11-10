//
//  DeepProcessor.swift
//  App
//
//  Created by x on 9/11/2022.
//

import Foundation
import CoreML

struct MeanStd: Decodable {
    let id:String
    let mean:Double
    let std:Double
}

class DeepProcessor : ObservableObject {
    let batch:NSNumber = 1
    let seq:NSNumber = 50
    let dim:NSNumber = 25
    var inputShape:[NSNumber] {[self.batch, self.seq, self.dim]}
    var model:rnnpos
    
    //MARK: - DeepProcessor Properties
//    let model = DeepPos()
    @Published var pos:Position?
    @Published var realPos:Position?
    var refPos:Position?
    static let maxNumRealPos: Int = 50
    static let maxNumPredPos: Int = 25
    var realPoses: [Position] = [Position(x:1,y: 0,z: 0,t: 0),Position(x: 2,y: 0,z: 0,t: 0),Position(x: 3,y: 0,z: 0,t: 0),Position(x: 4,y: 0,z: 0,t: 0)]
    var predPoses: [Position] = []
    static let minRealPosUpdateInterval: Double = 0.15
    /// analysis
    var squareError: Double?
    var squareErrors: [Double] = []
    static let maxNumSquareErr: Int = 1000
    //
    var txPoses: [Position] { TXManager.shared().txs.map { $0.value.pos }}
    /// prediction control
    private var predInterval:Double = 0.025
    private var prevPredTime:Double = Date().timeIntervalSince1970
    var prevMeasuredTime: Double = Date().timeIntervalSince1970

    //MARK: - DeepProcessor Singleton
    private static var _shared: DeepProcessor = {
        return DeepProcessor()
    }()
    class func shared() -> DeepProcessor {
        return self._shared
    }
    
    //MARK: - DeepProcessor Properties
    private(set) var txs : [String: [Double]] = [:] /// dictionary is not threading save in make sure all access are from same thread (e.g. main)
    var meanstd: [String:MeanStd] = [:]
    static let maxWindowSize = 50

    //MARK: - DeepProcessor Constructor
    private init() {
        
        guard let model = try? rnnpos() else {
            fatalError("Unable to load model")
        }
        self.model = model
        
        self.load()
        /// notification handler
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecvDataHandler(notification:)), name: Constant.NotificationNameWiTracingDidRecvData, object: nil)
    }
    
    //MARK: - DeepProcessor Notification Handler
    @objc private func didRecvDataHandler(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let txname = userInfo["txname"] as? String,
                let txx = userInfo["txx"] as? Double,
                let txy = userInfo["txy"] as? Double,
                let txz = userInfo["txz"] as? Double,
                let rxx = userInfo["rxx"] as? Double,
                let rxy = userInfo["rxy"] as? Double,
                let rxz = userInfo["rxz"] as? Double,
                let rssi = userInfo["rssi"] as? Int,
                let timestamp = userInfo["timestamp"] as? Double {
                let txPos = Position(x: txx, y: txy, z: txz, t: timestamp)
                let rxPos = Position(x: rxx, y: rxy, z: rxz, t: timestamp)

                DispatchQueue.main.async {
                    self.updateTX(txname: txname.lowercased(), rssi: rssi, timestamp: timestamp)

                }
                /// check if update is required
                var bUpdate: Bool = false
                if self.realPos == nil {
                    bUpdate = true
                } else if let prevPos = self.realPos {
                    if prevPos != pos {
                        bUpdate = true
                    }
                }
                /// update if necessary
                if bUpdate {
                    DispatchQueue.main.async {
                        self.updateRealPos(pos: rxPos)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
        /// handle prediction only exceed prediction interval
            let now = Date().timeIntervalSince1970
            guard now - self.prevPredTime > self.predInterval else {
                return
            }

            if let estimation = self.modelPredict() {
                self.updatePredPos(pos: estimation)
                self.prevPredTime = now
//               self.prevMeasuredTime = TXManager.shared().prevMeasuredTime
            }
        }
    }

    //MARK: - DeepProcessor Methods
    
    /// update transmitter
    /// =====================
    /// update transmitter information
    func updateTX(txname: String, rssi: Int, timestamp: Double) {
        /// if transmitter already in the group
        if let _ = self.txs[txname] {
            var normRssi:Double? = Double(Constant.MinRSSI)
            if rssi < Constant.MinRSSI {
                /// of rssi is undetactable, then use last measurement
                normRssi = self.txs[txname]?.last
            } else {
                normRssi = self.normalizeRSSI(txname: txname, rssi: rssi)
            }
            if let rssi = normRssi {
                self.txs[txname]?.append(rssi)
            }
            if self.txs[txname]!.count > DeepProcessor.maxWindowSize {
                self.txs[txname]?.remove(at: 0)
            }
            
        } else {
            /// if no measurement
            if let rssi = self.normalizeRSSI(txname: txname, rssi: rssi) {
                self.txs[txname] = [rssi]
            }
        }
        _ = self.getInput(shape: [1, 3, 25])
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
    
    func getSquareError() -> Double? {
        if let pos = self.pos, let realPos = self.refPos {
            return Position.xyDistance(lhs: pos, rhs: realPos)
        }
        return nil
    }
    
    /// Update the prediction position
    func updatePredPos(pos: Position) {
        if let prevPos = self.pos {
            if pos == prevPos {
                return
            }
        }
        self.pos = pos
        self.predPoses.append(pos)
        if self.predPoses.count > Predictor.maxNumPredPos {
            self.predPoses.remove(at: 0)
        }
        self.refPos = self.realPos
        self.updateSquareError()
    }
    /// Update the gound truth position
    func updateRealPos(pos: Position) {
        if let realPos = self.realPos {
            /// limit the update frequency for ground true
            if pos.t - realPos.t < Predictor.minRealPosUpdateInterval {
                return
            }
        }
        
        self.realPos = pos
        self.realPoses.append(pos)
        if self.realPoses.count > Predictor.maxNumRealPos {
            self.realPoses.remove(at: 0)
        }
        if (self.predPoses.count >= 4 && self.realPoses.count >= 4) {
            print("pred:", Array(self.predPoses[0...3]))
            print("real:", Array(self.realPoses[0...3]))
        }
        
    }
    /// Update the square error
    func updateSquareError() {
        if let error = self.getSquareError() {
            self.squareError = error
            self.squareErrors.append(error)
            if self.squareErrors.count > Predictor.maxNumSquareErr {
                self.squareErrors.remove(at: 0)
            }
        }
    }
    
    func modelPredict() -> Position? {
        guard let arr = self.getInput(shape: [self.batch.intValue, self.seq.intValue, self.dim.intValue]) else {
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

