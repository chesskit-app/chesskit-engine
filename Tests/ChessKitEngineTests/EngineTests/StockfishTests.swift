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

        let evalFileURL = Bundle.module
            .path(forResource: "nn-1337b1adec5b", ofType: "nnue")!
            .replacingOccurrences(of: "file://", with: "")

        engine.send(command: .setoption(id: "Eval File", value: evalFileURL))
        engine.send(command: .setoption(id: "Use NNUE", value: "true"))
    }
    
}
