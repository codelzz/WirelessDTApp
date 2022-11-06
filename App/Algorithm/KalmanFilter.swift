//
//  KalmanFilter.swift
//  App
//
//  Created by x on 6/11/2022.
//
//  ref: https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/HCKalmanFilter/HCKalmanAlgorithm.swift

import Foundation

class KalmanFilter {
    //MARK: - KalmanFilter properties

    /// The dimension M of the state vector
    private let dimM = 6
    /// The dimension N of the state vector
    private let dimN = 1

    /// Acceleration variance magnitude for GPS
    /// ======================================
    /// **Sigma** value is  value for Acceleration Noise Magnitude Matrix (Qt).
    private let sigma = 0.0625

    /// Value for Sensor Noise Covariance Matrix
    /// ========================================
    /// This value can be adjusted depending on the needs, the higher value
    /// of **rVaule** variable will give greater roundness trajectories, and vice versa.
    private var rValue: Double {
        set
        {
            _rValue = newValue
        }
        get
        {
            return _rValue
        }
    }
    private var _rValue: Double = 20.0

    /// Previous State Vector
    /// =====================
    /// **Previous State Vector** is mathematical representation of previous state of Kalman Filter.
    private var xk1:Mat

    /// Covariance Matrix for Previous State
    /// ====================================
    /// **Covariance Matrix for Previous State** is mathematical representation of covariance matrix for previous state of Kalman Filter.
    private var Pk1:Mat

    /// Prediction Step Matrix
    /// ======================
    /// **Prediction Step Matrix (A)** is mathematical representation of prediction step of Kalman Filter.
    /// Prediction Matrix gives us our next state. It takes every point in our original estimate and moves it to a new predicted location,
    /// which is where the system would move if that original estimate was the right one.
    private var A:Mat

    /// Acceleration Noise Magnitude Matrix
    /// ===================================
    /// **Acceleration Noise Magnitude Matrix (Qt)** is mathematical representation of external uncertainty of Kalman Filter.
    /// The uncertainty associated can be represented with the “world” (i.e. things we aren’t keeping track of)
    /// by adding some new uncertainty after every prediction step.
    private var Qt:Mat

    /// Sensor Noise Covariance Matrix
    /// ==============================
    /// **Sensor Noise Covariance Matrix (R)** is mathematical representation of sensor noise of Kalman Filter.
    /// Sensors are unreliable, and every state in our original estimate might result in a range of sensor readings.
    private var R:Mat

    /// Measured State Vector
    /// =====================
    /// **Measured State Vector (zt)** is mathematical representation of measuerd state vector of Kalman Filter.
    /// Value of this variable was readed from sensor, this is mean value to the reading we observed.
    private var zt:Mat!

    /// Previous State Position
    private var prevPos:Position

    //MARK - KalmanFilter initialization
    /// Initialization of Kalman Filter Constructor
    /// ==============================================
    /// - parameters:
    ///   - pos: this is Position which represent initial position at the moment when algorithm start
    init(pos: Position) {
        /// init state
        self.prevPos = pos
        /// xk1 (M, N) --- [x, vx, y, vy, z, vz].T
        self.xk1 = Mat(matrix: [[pos.x],[0.0],[pos.y],[0.0],[pos.z],[0.0]])
        /// Pk1 (M, M) --- covariance matrix for previous state
        self.Pk1 = Mat.makeZeroMatrix(rows: self.dimM, cols: self.dimM)
        /// A (M, M) --- prediction step matrix
        self.A = Mat.makeIdentityMatrix(dim: self.dimM)
        /// Qt (M, M)
        self.Qt = Mat(rows: self.dimM, cols: self.dimM)
        /// R (M, M) --- sensor noise covariance matrix
        self.R = (self._rValue * Mat.makeIdentityMatrix(dim: self.dimM))!
        /// zt (M, N)
        self.zt = Mat(rows: self.dimM, cols: self.dimN)
    }
    
    //MARK: - KalmanFilter methods
    
    /// Predict Current Position
    /// ========================
    ///  This function is a main. **processState** will be processed current location of user by Kalman Filter
    ///  based on previous state and other parameters, and it returns corrected location
    /// - parameters:
    ///   - pos: this is Position  which represent current position
    /// - returns: position with corrected x, y and z values
    func predict(pos: Position) -> Position {
        /// Calculate interval between last and current measure
        let interval = pos.t - self.prevPos.t
        /// Calculate and set Prediction Step Matrix based on new interval value
        A.setMatrix(matrix:[[1,interval,0,0,0,0],
                            [0,1,0,0,0,0],
                            [0,0,1,interval,0,0],
                            [0,0,0,1,0,0],
                            [0,0,0,0,1,interval],
                            [0,0,0,0,0,1]])
        /// Parts of Acceleration Noise Magnitude Matrix
        let p1 = self.sigma * pow(interval, 4.0) / 4.0
        let p2 = self.sigma * pow(interval, 3.0) / 2.0
        let p3 = self.sigma * pow(interval, 2.0)
        /// Calculate and set Acceleration Noise Magnitude Matrix based on new interval and sigma values
        Qt.setMatrix(matrix: [[p1,p2,0.0,0.0,0.0,0.0],
                              [p2,p3,0.0,0.0,0.0,0.0],
                              [0.0,0.0,p1,p2,0.0,0.0],
                              [0.0,0.0,p2,p3,0.0,0.0],
                              [0.0,0.0,0.0,0.0,p1,p2],
                              [0.0,0.0,0.0,0.0,p2,p3]])
        /// Calculate velocity components
        /// This is value of velocity between previous and current position. Distance traveled from the previous to the current position divided by interval between two measurement.
        let vx = (self.prevPos.x - pos.x) / interval
        let vy = (self.prevPos.y - pos.y) / interval
        let vz = (self.prevPos.z - pos.z) / interval
        
        // Set Measured State Vector; current x, y, z and vx, vy and vz
        zt.setMatrix(matrix:[[pos.x],[vx],[pos.y],[vy],[pos.z],[vz]])
        
        // Set previous Location and Measure Time for next step of processState function.
        self.prevPos = pos
        
        // Return value of kalmanFilter
        return self.step()
    }
    
    /// Kalman Filter Function
    /// ======================
    /// This is additional function, which helps in the process of correcting location
    /// Here happens the whole mathematics related to Kalman Filter. Here is the essence.
    /// The algorithm consists of two parts - Part of Prediction and Part of Update State
    ///
    /// Prediction part performs the prediction of the next state based on previous state, prediction matrix (A) and takes into consideration
    /// external uncertainty factor (Qt). It returns predicted state and covariance matrix -> xk, Pk
    ///
    /// Next step is Update part. It combines predicted state with sensor measurement. Update part first calculate Kalman gain (Kt).
    /// Kalman gain takes into consideration sensor noice. Next based on this value, value of predicted state and value of measurement,
    /// algorithm can calculate new state, and function return corrected x, y and z values in Position .
    private func step() -> Position {
        let xk = self.A * self.xk1
        let Pk = ((self.A*self.Pk1)! * self.A.T()!)! + self.Qt
        let tmp = Pk! + self.R
        let Kt = Pk!*(tmp?.inv())! // Kalman gain (Kt)
        let xt = xk! + (Kt! * (zt - xk!)!)!
        let Pt = (Mat.makeIdentityMatrix(dim: self.dimM) - Kt!)! * Pk!
        self.xk1 = xt!
        self.Pk1 = Pt!
        return Position(x: self.xk1[0,0], y: self.xk1[2,0], z: self.xk1[4,0], t: self.prevPos.t)
    }
}
