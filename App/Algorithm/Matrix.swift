//
//  Matrix.swift
//  App
//
//  Created by x on 6/11/2022.
//
//  ref: https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/HCKalmanFilter/HCMatrixObject.swift


import Foundation
import Surge

class Mat {
    //MARK: - Matrix properties
    
    /// Number of Rows in Matrix
    private var rows: Int
    /// Number of Columns in Matrix
    private var cols: Int
    /// Surge Matrix object
    var matrix:Matrix<Double> {
        set(newValue) {
            self.matrix = newValue
            /// always synchronize the shape when Matrix update
            self.rows = self.matrix.rows
            self.cols = self.matrix.columns
        }
        get {
            return self.matrix
        }
    }
    
    //MARK: - Matrix Error
    private enum MatError: Error {
        case IndexOutOfBounds
    }
    
    //MARK: - Initialization
    
    /// Initailization of matrix with specified numbers of rows and columns
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.matrix = Matrix(rows: self.rows, columns: self.cols, repeatedValue: 0.0)
    }
    
    init(matrix: Matrix<Double>) {
        self.rows = matrix.rows
        self.cols = matrix.columns
        self.matrix = matrix
    }
    
    //MARK: - Matrix Method
    
    /// makeIdentityMatrix Function
    /// ==========================
    /// For some dimension dim, return identity matrix object
    ///
    /// - parameters:
    ///   - dim: dimension of desired identity matrix
    /// - returns: identity matrix object
    static func makeIdentityMatrix(dim:Int) -> Mat {
        let m = Mat(rows: dim, cols: dim)
        for i in 0..<dim {
            for j in 0..<dim {
                if i == j {
                    m.matrix[i,j] = 1.0
                }
            }
        }
        return m
    }
    
//    /// addElement Function
//    /// ===================
//    /// Add double value on (i,j) position in matrix
//    ///
//    /// - parameters:
//    ///   - row: row of matrix
//    ///   - col: column of matrix
//    ///   - value: double value to add in matrix
//    /// - returns: if operation success
//    public func addElement(row:Int,col:Int,value:Double) {
//        if self.indexIsValid(row: row, col: col) {
//            self.matrix[row, col] = value
//        }
//    }
    
    /// setMatrix Function
    /// ==================
    /// Set complete matrix
    ///
    /// - parameters:
    ///   - matrix: array of array of double values
    func setMatrix(matrix:[[Double]]) {
        if self.matrix.rows > 0 {
            if (matrix.count == self.matrix.rows) && (matrix[0].count == self.matrix.columns) {
                self.matrix = Matrix<Double>(matrix)
            }
        }
    }
    
//    /// getElement Function
//    /// ===================
//    /// Returns double value on specific position of matrix
//    ///
//    /// - parameters:
//    ///   - i: row of matrix
//    ///   - j: column of matrix
//
//    public func getElement(i:Int,j:Int) -> Double?
//    {
//        if self.matrix.rows <= i && self.matrix.columns <= j
//        {
//            return self.matrix[i,j]
//        }
//        else
//        {
//            print("error")
//            return nil
//        }
//    }
//
    private func indexIsValid(row: Int, col: Int) -> Bool {
        return row >= 0 && row < self.rows && col >= 0 && col <= self.cols
    }
    
    func isSquareMatrix() -> Bool {
        return self.rows > 0 && self.rows == self.cols
    }
    
    func hasSameShape(with: Mat) -> Bool {
        return self.rows == with.rows && self.cols == with.cols
    }
    
    /// Transpose Matrix
    /// =========================
    /// Returns transposed matrix
    ///
    /// - returns: transposed Mat
    func transpose() -> Mat? {
        let m = Mat(rows: self.cols, cols: self.rows)
        m.matrix = Surge.transpose(self.matrix)
        return m
    }
    
    /// Inverse Matrix Function
    /// =======================
    /// Returns inverse matrix
    ///
    /// - returns: inverse matrix object
    func inverseMatrix() -> Mat? {
        assert(self.isSquareMatrix(), "[ERR] Attempt to inverse non-square matrix")
        let m = Mat(rows: self.rows, cols: self.cols)
        m.matrix = Surge.inv(self.matrix)
        return m
    }
    
    /// Print Matrix Function
    /// =====================
    /// Printing the entire matrix
    func debugprint() {
        for i in 0..<self.rows {
            for j in 0..<self.cols {
                print("\(self[i,j]) ")
            }
            print("---")
        }
    }
    
    //MARK: - Predefined Mat operators
    
    /// Predefined subscript operator
    /// =====================
    /// indexing the value from matrix
    ///
    /// - parameters:
    ///   - row: row of matrix
    ///   - col: column of matrix
    subscript(row: Int, col: Int) -> Double {
        get {
            assert(indexIsValid(row: row, col: col), "[ERR] Out of bounds read")
            return self.matrix[row, col]
        }
        set (newValue) {
            assert(indexIsValid(row: row, col: col), "[ERR] Out of bounds write")
            self.matrix[row, col] = newValue
        }
    }
    
    /// Predefined + operator
    /// =====================
    /// Returns result Mat of addition operation
    ///
    /// - parameters:
    ///   - lhs: left addition Mat operand
    ///   - rhs: right addition Mat operand
    /// - returns: result Mat of addition operation
    static func +(lhs:Mat, rhs:Mat) -> Mat? {
        assert(lhs.hasSameShape(with: rhs), "[ERROR] Attampt to add matrix with different shape")
        let m = Mat(rows: lhs.rows, cols: lhs.cols)
        m.matrix = Surge.add(lhs.matrix, rhs.matrix)
        return m
    }
    
    /// Predefined - operator
    /// =====================
    /// Returns result Mat of subtraction operation
    ///
    /// - parameters:
    ///   - lhs: left subtraction Mat operand
    ///   - rhs: right addition Mat operand
    /// - returns: result Mat object of subtraction operation
    static func -(lhs:Mat, rhs:Mat) ->Mat? {
        assert(lhs.hasSameShape(with: rhs), "[ERROR] Attampt to subtract matrix with different shape")
        let m = Mat(matrix: Surge.mul(-1.0, rhs.matrix))
        return lhs + m
    }
    
    /// Predefined * operator
    /// =====================
    /// Returns result Mat of multiplication operation
    ///
    /// - parameters:
    ///   - lhs: left multiplication Mat operand
    ///   - rhs: right multiplication Mat operand
    /// - returns: result Mat of multiplication operation
    static func *(lhs:Mat, rhs:Mat) -> Mat? {
        return Mat(matrix: Surge.mul(lhs.matrix, rhs.matrix))
    }
}
