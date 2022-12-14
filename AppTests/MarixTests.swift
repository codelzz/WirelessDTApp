//
//  AppTests.swift
//  AppTests
//
//  Created by x on 6/11/2022.
//

import XCTest
import Surge

final class MatrixTests: XCTestCase {
    
    func testMatAddiction() {
        let rhs = Mat(matrix: [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
        let lhs = Mat(matrix: [[2.0, 2.0], [1.0, 1.0], [3.0, 3.0]])
        let answer = Mat(matrix: [[3.0, 4.0], [4.0, 5.0], [8.0, 9.0]])
        let result = rhs + lhs
        XCTAssertEqual(result, answer)
    }
    
    func testMatSubtraction() {
        let rhs = Mat(matrix: [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
        let lhs = Mat(matrix: [[2.0, 2.0], [1.0, 1.0], [3.0, 3.0]])
        let answer = Mat(matrix: [[-1.0, 0.0], [2.0, 3.0], [2.0, 3.0]])
        let result = rhs - lhs
        XCTAssertEqual(result, answer)
    }
    
    func testMatTranspose() {
        let matrix = Mat(matrix: [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
        let answer = Mat(matrix: [[1.0, 3.0, 5.0],[2.0, 4.0, 6.0]])
        let result = matrix.T
        XCTAssertEqual(result, answer)
    }
    
    func testMatInverse() {
        let matrix = Mat(matrix: [[2, 0], [0, 2]])
        let answer = Mat(matrix: [[0.5, 0], [0, 0.5]])
        let result = matrix.inv
        XCTAssertEqual(result, answer)
    }
    
    func testMakeZeroMatrix() {
        let dimM = 3
        let dimN = 6
        let answer = Mat(matrix: [[0.0,0.0,0.0,0.0,0.0,0.0],
                                  [0.0,0.0,0.0,0.0,0.0,0.0],
                                  [0.0,0.0,0.0,0.0,0.0,0.0]])
        let result = Mat.makeZeroMatrix(rows: dimM, cols: dimN)
        XCTAssertEqual(result, answer)
    }
    
    func testMakeIdentityMatrix() {
        let dim = 6
        let answer = Mat(matrix: [[1.0,0.0,0.0,0.0,0.0,0.0],
                                  [0.0,1.0,0.0,0.0,0.0,0.0],
                                  [0.0,0.0,1.0,0.0,0.0,0.0],
                                  [0.0,0.0,0.0,1.0,0.0,0.0],
                                  [0.0,0.0,0.0,0.0,1.0,0.0],
                                  [0.0,0.0,0.0,0.0,0.0,1.0]])
        let result = Mat.makeIdentityMatrix(dim: dim)
        XCTAssertEqual(result, answer)
    }
    
    func testVectorMultiplication() {
        let lhs = Mat(matrix: [[1,2,3]])
        let rhs = Mat(matrix: [[1,2,3]])
        let answer = lhs * rhs.T
        let result = Mat(matrix: [[14.0]])
        XCTAssertEqual(result, answer)
    }
}
