//
//  AppTests.swift
//  AppTests
//
//  Created by x on 6/11/2022.
//

import XCTest
import Surge

final class AppTests: XCTestCase {
    
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
        let result = matrix.T()
        XCTAssertEqual(result, answer)
    }
    
    func testMatInverse() throws {
        let matrix = Mat(matrix: [[2, 0], [0, 2]])
        let answer = Mat(matrix: [[0.5, 0], [0, 0.5]])
        let result = matrix.inv()
        XCTAssertEqual(result, answer)
    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
