//
//  BaseEngineTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import XCTest

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
@EngineTestActor
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

  override func setUp() async throws {
    try await super.setUp()
    engine = Engine(type: engineType)
  }

  override func tearDown() async throws {
    engine = nil
  }

  // MARK: Test Cases

  func testLogging() async {
    XCTAssert(!Thread.isMainThread, "Test must be run on a background thread")
    XCTAssertNotNil(engine, "Failed to initialize engine")

    await engine.set(loggingEnabled: true)
    let l1 = await engine.loggingEnabled
    XCTAssertTrue(l1)

    await engine.set(loggingEnabled: false)
    let l2 = await engine.loggingEnabled
    XCTAssertFalse(l2)
  }

  func testEngineStart() async throws {
    XCTAssert(!Thread.isMainThread, "Test must be run on a background thread")
    XCTAssertNotNil(engine, "Failed to initialize engine")

    let expectation = expectation(
      description: "Expect engine \(engine.type.name) to start up."
    )

    await startEngine(expectation: expectation)
    await fulfillment(of: [expectation], timeout: 5)
  }

  func testEngineStop() async throws {
    XCTAssert(!Thread.isMainThread, "Test must be run on a background thread")
    XCTAssertNotNil(engine, "Failed to initialize engine")

    let expectationStartEngine = expectation(
      description: "Expect engine \(engine.type.name) to start up."
    )
    let expectationStopEngine = expectation(
      description: "Expect engine \(engine.type.name) to stop gracefully."
    )

    await startEngine(expectation: expectationStartEngine)
    await stopEngine(expectation: expectationStopEngine)
    await fulfillment(of: [expectationStartEngine, expectationStopEngine], timeout: 5)
  }

  func testEngineRestart() async throws {
    XCTAssert(!Thread.isMainThread, "Test must be run on a background thread")
    XCTAssertNotNil(self.engine, "Failed to initialize engine")

    let expectationStartEngine = expectation(
      description: "Expect engine \(engine.type.name) to start up."
    )
    let expectationStopEngine = expectation(
      description: "Expect engine \(engine.type.name) to stop gracefully."
    )

    expectationStartEngine.expectedFulfillmentCount = 2

    await startEngine(expectation: expectationStartEngine)
    await stopEngine(expectation: expectationStopEngine)

    // Give time for deinitialization processes to complete
    try await Task.sleep(for: .milliseconds(100))

    await startEngine(expectation: expectationStartEngine)
    await fulfillment(of: [expectationStartEngine, expectationStopEngine], timeout: 5)
  }

  // MARK: Convenience

  private func startEngine(expectation: XCTestExpectation) async {
    await engine.start()

    for await response in await engine.responseStream! {
      if case let .id(id) = response, case let .name(name) = id {
        XCTAssertTrue(name.contains(engine.type.version))
      }

      if await engine.isRunning, response == .readyok {
        expectation.fulfill()
        break
      }
    }
  }

  private func stopEngine(expectation: XCTestExpectation) async {
    await engine.stop()

    if await !engine.isRunning, await engine.responseStream == nil {
      expectation.fulfill()
    }
  }
}

// MARK: - EngineTestActor

/// Ensures tests for the `Engine` class don't run on main thread.
///
/// Since `[EngineMessenger start]` function now uses
/// `dispatch_async(dispatch_get_main_queue, (), ^{...});`
/// which is the main thread to listen for read notifications,
/// testing on main thread is counter productive.
@globalActor
actor EngineTestActor: GlobalActor {
  static let shared = EngineTestActor()
}
