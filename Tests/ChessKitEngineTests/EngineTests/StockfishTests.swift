//
//  StockfishTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

final class StockfishTests: BaseEngineTests {
    
    override func setUp() {
        engineType = .stockfish
        super.setUp()
    }
    
}
