//
//  BaseEngineTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine
import Combine

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
    var cancellables: Set<AnyCancellable> = []

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
        let expectation = self.expectation(
            description: "Expect engine \(engine.type.name) to start up."
        )
        
        engine.responsePublisher.sink{ [weak self] response in
            guard let self else { return }

            if case let .id(id) = response, case let .name(name) = id {
                XCTAssertTrue(name.contains(engine.type.version))
            }

            if response == .readyok &&
                engine.isRunning {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        engine.start()
        wait(for: [expectation], timeout: 5)
    }
}
