//
//  EngineCommandPositionTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

class EngineCommandPositionTests: XCTestCase {
    
    func testPositionStringRawValue() {
        let p = EngineCommand.PositionString.startpos
        XCTAssertEqual(p.rawValue, "startpos")
        
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        let f = EngineCommand.PositionString.fen(fen)
        XCTAssertEqual(f.rawValue, "fen \(fen)")
    }
    
    func testPositionStringRawValueInit() {
        XCTAssertEqual(
            EngineCommand.PositionString(rawValue: "startpos"),
            .startpos
        )
        
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        XCTAssertEqual(
            EngineCommand.PositionString(rawValue: "fen \(fen)"),
            .fen(fen)
        )
    }
    
    
    func testInvalidFENPositionStrings() {
        let fen1 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        XCTAssertNil(EngineCommand.PositionString(rawValue: "fen \(fen1)"))
        
        let fen2 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
        XCTAssertNil(EngineCommand.PositionString(rawValue: "fen \(fen2)"))
        
        let fen3 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq"
        XCTAssertNil(EngineCommand.PositionString(rawValue: "fen \(fen3)"))
        
        let fen4 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"
        XCTAssertNil(EngineCommand.PositionString(rawValue: "fen \(fen4)"))
        
        let fen5 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0"
        XCTAssertNil(EngineCommand.PositionString(rawValue: "fen \(fen5)"))
    }
    
    func testInvalidPositionString() {
        XCTAssertNil(EngineCommand.PositionString(rawValue: "invalid"))
        XCTAssertNil(EngineCommand.PositionString(rawValue: ""))
    }
    
}
