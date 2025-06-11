//
//  Lc0Tests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

final class Lc0Tests: BaseEngineTests {

  override func setUp() {
    engineType = .lc0
    super.setUp()
  }

  override func testEngineRestart() async {
    XCTAssert(!Thread.isMainThread, "Test must be run on a background thread")
    XCTAssertNotNil(self.engine, "Failed to initialize engine")

    let expectationStartEngine = self.expectation(
      description: "Expect engine \(engine.type.name) to start up."
    )
    let expectationStopEngine = self.expectation(
      description: "Expect engine \(engine.type.name) to stop gracefully."
    )

    expectationStartEngine.expectedFulfillmentCount = 2

    await startEngine(expectation: expectationStartEngine)
    await stopEngine(expectation: expectationStopEngine)

    // lc0 has an internal mutex failure "Unhandled exception: mutex lock failed: Invalid argument"
    // when trying to stop and start the engine too fast.
    // This 100 ms delay circumvents the issue.
    //
    // Once this issue is resolved, this function
    // can be removed, using `BaseEngineTests.testEngineRestart()` instead.
    try? await Task.sleep(for: .milliseconds(100))
    await startEngine(expectation: expectationStartEngine)

    await fulfillment(of: [expectationStartEngine, expectationStopEngine], timeout: 5)
  }
}
