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
    
    var engine: Engine!
    
    override func setUp() {
        super.setUp()
        
        engine = Engine(type: engineType)
    }
    
    override func tearDown() {
        engine.stop()
        engine = nil
        super.tearDown()
    }
    
    func testEngineSetup() {
        let expectation = XCTestExpectation()

        engine.start { [self] in
            engine.send(command: .isready)
        }

        engine.receiveResponse = {
            if $0 == .readyok {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
}
