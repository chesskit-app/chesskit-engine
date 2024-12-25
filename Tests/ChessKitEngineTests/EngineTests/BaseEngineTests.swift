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
/// #### Example
/// ``` swift
/// final class MyEngineTests: BaseEngineTests {
///
///     func override setUp() {
///         engineType = .myEngine
///         super.setUp()
///     }
///
/// }
/// ```
///
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
    var engine: Engine!

    override func setUp() {
        super.setUp()
        engine = Engine(type: engineType)
    }

    override func tearDown() async throws {
        await engine.stop()
        engine = nil
        try? await super.tearDown()
    }

    func testEngineSetup() async {
        let expectation = self.expectation(
            description: "Expect engine \(engine.type.name) to start up."
        )
        
        guard let engine = self.engine else {
            XCTFail("Engine is nil")
            return
        }
        
        engine.start()
        
        Task{
            for await response in await engine.responseChannel! {
                if case let .id(id) = response,
                    case let .name(name) = id {
                    let version = engine.type.version
                    XCTAssertTrue(name.contains(version))
                }
                
                let isRunning = await engine.isRunning
                
                if response == .readyok &&
                    isRunning {
                    expectation.fulfill()
                }
            }
        }
        await fulfillment(of: [expectation], timeout: 5)
    }

    func testEngineStop() async {
        let expectationStartEngine = self.expectation(
            description: "Expect engine \(engine.type.name) to start up."
        )
        
        let expectationStopEngine = self.expectation(
            description: "Expect engine \(engine.type.name) to stop gracefully."
        )
        
        guard let engine = self.engine else {
            XCTFail("Engine is nil")
            return
        }
        
        engine.start()
            
        Task{
            for await response in await engine.responseChannel! {
                let isRunning = await engine.isRunning
                
                if response == .readyok &&
                    isRunning {
                    expectationStartEngine.fulfill()
                    break
                }
            }
            
            await engine.stop()
            
            if await !engine.isRunning,
               await engine.responseChannel == nil {
                expectationStopEngine.fulfill()
            }
        }
        
        await fulfillment(of: [expectationStartEngine, expectationStopEngine], timeout: 5)
    }
}


@globalActor
actor TestActor: GlobalActor {
    public static var shared = TestActor()
}
