//
//  Matrix.swift
//  App
//
//  Created by x on 6/11/2022.
//
//  ref: https://github.com/Hypercubesoft/HCKalmanFilter/blob/master/HCKalmanFilter/HCMatrixObject.swift


import Foundation
import Surge

public class Mat : Equatable {
    //MARK: - Matrix properties
    
    /// Number of Rows in Matrix
    public private(set) var rows: Int
    /// Number of Columns in Matrix
    public private(set) var cols: Int
    /// Surge Matrix object
    private var _matrix:Matrix<Double> = [[0.0]]
    private var matrix:Matrix<Double> {
        set {
            /// synchronize the shape
            self.rows = newValue.rows
            self.cols = newValue.columns
            self._matrix = newValue
        }
        get {
            return self._matrix
        }
    }
    
    //MARK: - Matrix Error
    private enum MatError: Error {
        case IndexOutOfBounds
    }
    
    //MARK: - Initialization
    
    /// Initailization of Mat with specified numbers of rows and columns
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.matrix = Matrix(rows: self.rows, columns: self.cols, repeatedValue: 0.0)
    }
    
    /// Initailization of Mat with matrix
    init(matrix: Matrix<Double>) {
        self.rows = matrix.rows
        self.cols = matrix.columns
        self.matrix = Matrix(matrix)
    }
    
    //MARK: - Matrix Method
    
    /// makeIdentityMatrix Function
    /// ==========================
    /// For some dimension dim, return identity matrix object
    ///
    /// - parameters:
    ///   - dim: dimension of desired identity matrix
    /// - returns: identity matrix object
    static public func makeIdentityMatrix(dim:Int) -> Mat {
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
    
    /// makeZeroMatrix Function
    /// ==========================
    /// For some dimension dim, return identity matrix
    ///
    /// - parameters:
    ///   - dim: dimension of desired zero matrix
    /// - returns: zero matrix
    static public func makeZeroMatrix(rows: Int, cols: Int) -> Mat {
        return Mat(rows: rows, cols: cols)
    }
    
    /// setMatrix Function
    /// ==================
    /// Set complete matrix
    ///
    /// - parameters:
    ///   - matrix: array of array of double values
    public func setMatrix(matrix:[[Double]]) {
        if self.matrix.rows > 0 {
            if (matrix.count == self.matrix.rows) && (matrix[0].count == self.matrix.columns) {
                self.matrix = Matrix<Double>(matrix)
            }
        }
    }
    
    private func indexIsValid(row: Int, col: Int) -> Bool {
        return row >= 0 && row < self.rows && col >= 0 && col <= self.cols
    }
    
    public func isSquareMatrix() -> Bool {
        return self.rows > 0 && self.rows == self.cols
    }
    
    public func hasSameShape(with: Mat) -> Bool {
        return self.rows == with.rows && self.cols == with.cols
    }
    
    /// Transpose Matrix
    var T:Mat { Mat(matrix: Surge.transpose(self.matrix))}
    
    /// Inverse Matrix
    var inv: Mat { Mat(matrix: Surge.inv(self.matrix)) }
    
    /// Determinant
    var det: Double? { Surge.det(self.matrix)}
    
    /// Print Matrix Function
    /// =====================
    /// Printing the entire matrix
    public func debugprint() {
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
    static public func +(lhs:Mat, rhs:Mat) -> Mat {
        assert(lhs.hasSameShape(with: rhs), "[ERROR] Attampt to add matrix with different shape")
        return Mat(matrix: Surge.add(lhs.matrix, rhs.matrix))
    }
    
    /// Predefined - operator
    /// =====================
    /// Returns result Mat of subtraction operation
    ///
    /// - parameters:
    ///   - lhs: left subtraction Mat operand
    ///   - rhs: right addition Mat operand
    /// - returns: result Mat object of subtraction operation
    static public func -(lhs:Mat, rhs:Mat) -> Mat {
        assert(lhs.hasSameShape(with: rhs), "[ERROR] Attampt to subtract matrix with different shape")
        return lhs + Mat(matrix: Surge.mul(-1.0, rhs.matrix))
    }
    
    /// Predefined * operator
    /// =====================
    /// Returns result Mat of multiplication operation
    ///
    /// - parameters:
    ///   - lhs: left multiplication Mat operand
    ///   - rhs: right multiplication Mat operand
    /// - returns: result Mat of multiplication operation
    static public func *(lhs:Mat, rhs:Mat) -> Mat {
        return Mat(matrix: Surge.mul(lhs.matrix, rhs.matrix))
    }
    
    /// Predefined * operator
    /// =====================
    /// Returns result Mat of multiplication operation
    ///
    /// - parameters:
    ///   - lhs: left multiplication Mat operand
    ///   - rhs: right multiplication Mat operand
    /// - returns: result Mat of multiplication operation
    static public func * (lhs:Double, rhs: Mat) -> Mat {
        return Mat(matrix: Surge.mul(lhs, rhs.matrix))
    }
    
    /// Predefined == operator
    /// =====================
    /// Returns result Mat of multiplication operation
    ///
    /// - parameters:
    ///   - lhs: left multiplication Mat operand
    ///   - rhs: right multiplication Mat operand
    /// - returns: result Mat of multiplication operation
    static public func == (lhs:Mat, rhs:Mat) -> Bool {
        return lhs.matrix == rhs.matrix
    }
}
