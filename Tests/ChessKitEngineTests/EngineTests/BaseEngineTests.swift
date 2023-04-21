//
//  BaseEngineTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

/// Base test case for testing included engines.
///
/// Subclass `BaseEngineTests`, set `engineType` in `setUp()`,
/// and then call `super.setUp()` to run common engine tests.
///
/// For example:
///
/// ```
/// final class MyEngineTests: BaseEngineTests {
///
///     func override setUp() {
///         engineType = .myEngine
///         super.setUp()
///     }
///
/// }
/// ```
class BaseEngineTests: XCTestCase {
    
    override class var defaultTestSuite: XCTestSuite {
        // Disable tests in base test case with empty XCTestSuite
        if self == BaseEngineTests.self {
            return .init(name: "Disable BaseEngineTests")
        } else {
            return super.defaultTestSuite
        }
    }
    
    /// The engine type to test.
    var engineType: EngineType!
    /// The expected evaluation range for the engine in
    /// the standard starting position.
    var expectedStartingEvaluation: ClosedRange<Double> = 1...60
    
    private var engine: Engine!
    
    override func setUp() {
        super.setUp()
        
        engine = Engine(type: engineType)
        engine.start()
    }
    
    override func tearDown() {
        engine.stop()
        engine = nil
        super.tearDown()
    }
    
    func testEngineUCISetup() {
        let expectation = XCTestExpectation()
        
        engine.receiveResponse = {
            if $0 == .uciok {
                expectation.fulfill()
            }
        }
        
        engine.send(command: .uci)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testEngineEvaluation() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 10
        var engineResponses = [EngineResponse]()
        
        engine.receiveResponse = {
            engineResponses.append($0)
            expectation.fulfill()
        }
        
        engine.send(command: .position(.startpos))
        engine.send(command: .go(depth: 5))
        
        wait(for: [expectation], timeout: 5)
        
        var infoCount = 0
        var score = 0.0

        engineResponses.forEach {
            switch $0 {
            case .info(let i):
                infoCount += 1
                if let cp = i.score?.cp {
                    score = cp
                }
            default:
                break
            }
        }
        
        XCTAssertGreaterThanOrEqual(
            score,
            expectedStartingEvaluation.lowerBound
        )
        
        XCTAssertLessThanOrEqual(
            score,
            expectedStartingEvaluation.upperBound
        )
    }
    
}
