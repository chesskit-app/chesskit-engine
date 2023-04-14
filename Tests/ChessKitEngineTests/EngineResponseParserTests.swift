//
//  EngineResponseParserTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

final class EngineResponseParserTests: XCTestCase {
    
    func test_invalid_command() {
        let invalid = "invalidcommand test"
        XCTAssertNil(EngineResponseParser.parse(response: invalid))
        
        let empty = ""
        XCTAssertNil(EngineResponseParser.parse(response: empty))
    }
    
    func test_parse_id() {
        let inputName = "id name Engine Name"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputName),
            .id(.name("Engine Name"))
        )
        
        let inputAuthor = "id author Engine Author"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputAuthor),
            .id(.author(("Engine Author")))
        )
        
        let idInvalid = "id invalid input"
        XCTAssertNil(EngineResponseParser.parse(response: idInvalid))
    }
    
    func test_parse_uciok() {
        let input = "uciok"
        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .uciok
        )
    }
    
    func test_parse_readyok() {
        let input = "readyok"
        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .readyok
        )
    }
    
    func test_parse_bestmove() {
        let inputBestMove = "bestmove e2e4"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputBestMove),
            .bestmove(move: "e2e4", ponder: nil)
        )
        
        let inputPonder = "bestmove e2e4 ponder e7e5"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputPonder),
            .bestmove(move: "e2e4", ponder: "e7e5")
        )
        
        let bestmoveInvalid = "bestmove"
        XCTAssertNil(EngineResponseParser.parse(response: bestmoveInvalid))
    }
    
    func test_info() {
        let input = "info depth 1 seldepth 0 score cp 8.37 mate -4 upperbound pv e2e4 e7e5 g1f3 nodes 10 currline 4 d2d4 g8f6 c2c4 e7e6 nps 8 string This is a test string with real tokens inserted such as pv and nodes and score lowerbound."
        let output = EngineResponse.Info(
            depth: 1,
            seldepth: 0,
            nodes: 10,
            pv: ["e2e4", "e7e5", "g1f3"],
            score: .init(
                cp: 8.37,
                mate: -4,
                upperbound: true
            ),
            nps: 8,
            string: "This is a test string with real tokens inserted such as pv and nodes and score lowerbound.",
            currline: .init(
                cpunr: 4,
                moves: ["d2d4", "g8f6", "c2c4", "e7e6"]
            )
        )
        
        if case let .info(result) = EngineResponseParser.parse(response: input) {
            XCTAssertEqual(result, output)
        } else {
            XCTFail("Result does not produce expected EngineResponse.Info")
        }
    }

}
