//
//  ArasanTests.swift
//
//  Created by Chris Ameter on 10/20/23.
//

import XCTest
@testable import ChessKitEngine

final class ArasanTests: BaseEngineTests {
    
    override func setUp() {
        engineType = .arasan
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
        try? await Task.sleep(for: .seconds(1))
        await stopEngine(expectation: expectationStopEngine)
        try? await Task.sleep(for: .seconds(1))
        await startEngine(expectation: expectationStartEngine)
        
        await fulfillment(of: [expectationStartEngine, expectationStopEngine], timeout: 5)
    }
}
