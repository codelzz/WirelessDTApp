//
//  KalmanFilter.swift
//  App
//
//  Created by x on 6/11/2022.
//
//  ref: https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/HCKalmanFilter/HCKalmanAlgorithm.swift

import Foundation

//class KalmanFilter {
//    // MARK: KalmanFilter properties
//    
//    /// The dimension M of the state vector
//    static private let dimM = 6
//    /// The dimension N of the state vector
//    static private let dimN = 1
//    
//    /// Acceleration variance magnitude for GPS
//    /// ======================================
//    /// **Sigma** value is  value for Acceleration Noise Magnitude Matrix (Qt).
//    /// Recommended value for **sigma** is 0.0625, this value is optimal for GPS problem,
//    /// it was concluded by researches.
//    private static let sigma = 0.0625
//    
//    /// Value for Sensor Noise Covariance Matrix
//    /// ========================================
//    /// Default value is 29.0, this is the recommended value for the GPS problem, with this value filter provides optimal accuracy.
//    /// This value can be adjusted depending on the needs, the higher value
//    /// of **rVaule** variable will give greater roundness trajectories, and vice versa.
//    open var rValue: Double {
//            set {_rValue = newValue}
//            get { return _rValue}
//    }
//    
//    private var _rValue: Double = 29.0
//    
//    /// Previous State Vector
//    /// =====================
//    /// **Previous State Vector** is mathematical representation of previous state of Kalman Algorithm.
//    private var xk1:Matrix
//}
