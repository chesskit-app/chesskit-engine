//
//  EngineResponseParserTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

final class EngineResponseParserTests: XCTestCase {

    func testInvalidResponse() {
        let invalid = "invalidcommand test"
        XCTAssertNil(EngineResponseParser.parse(response: invalid))
        XCTAssertNil(EngineResponse(rawValue: invalid))

        let empty = ""
        XCTAssertNil(EngineResponseParser.parse(response: empty))
        XCTAssertNil(EngineResponse(rawValue: empty))
    }

    func testParseID() {
        let inputName = "id name Engine Name"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputName),
            .id(.name("Engine Name"))
        )
        XCTAssertEqual(
            EngineResponse(rawValue: inputName),
            .id(.name("Engine Name"))
        )

        let inputAuthor = "id author Engine Author"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputAuthor),
            .id(.author(("Engine Author")))
        )
        XCTAssertEqual(
            EngineResponse(rawValue: inputAuthor),
            .id(.author(("Engine Author")))
        )

        let idInvalid = "id invalid input"
        XCTAssertNil(EngineResponseParser.parse(response: idInvalid))
        XCTAssertNil(EngineResponse(rawValue: idInvalid))
    }

    func testParseUciok() {
        let input = "uciok"
        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .uciok
        )
        XCTAssertEqual(
            EngineResponse(rawValue: input),
            .uciok
        )
    }

    func testParseReadyok() {
        let input = "readyok"
        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .readyok
        )
        XCTAssertEqual(
            EngineResponse(rawValue: input),
            .readyok
        )
    }

    func testParseBestMove() {
        let inputBestMove = "bestmove e2e4"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputBestMove),
            .bestmove(move: "e2e4", ponder: nil)
        )
        XCTAssertEqual(
            EngineResponse(rawValue: inputBestMove),
            .bestmove(move: "e2e4", ponder: nil)
        )

        let inputPonder = "bestmove e2e4 ponder e7e5"
        XCTAssertEqual(
            EngineResponseParser.parse(response: inputPonder),
            .bestmove(move: "e2e4", ponder: "e7e5")
        )
        XCTAssertEqual(
            EngineResponse(rawValue: inputPonder),
            .bestmove(move: "e2e4", ponder: "e7e5")
        )

        let inputBestMoveWithNewline1 = "bestmove\nc8d7 ponder e1c1"
        XCTAssertEqual(
            EngineResponse(rawValue: inputBestMoveWithNewline1),
            .bestmove(move: "c8d7", ponder: "e1c1")
        )

        let inputBestMoveWithNewline2 = "bestmove \nc8d7 ponder e1c1"
        XCTAssertEqual(
            EngineResponse(rawValue: inputBestMoveWithNewline2),
            .bestmove(move: "c8d7", ponder: "e1c1")
        )

        let bestmoveInvalid = "bestmove"
        XCTAssertNil(EngineResponseParser.parse(response: bestmoveInvalid))
        XCTAssertNil(EngineResponse(rawValue: bestmoveInvalid))
    }

    func testParseInfo() {
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

        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .info(output)
        )
        XCTAssertEqual(
            EngineResponse(rawValue: input),
            .info(output)
        )
    }

    func testParseExtraInfo() {
        let input = "info time 1 multipv 2 currmove e2e4 currmovenumber 3 hashfull 4.56 tbhits 7 sbhits 8 cpuload 9 refutation c7c5 d2d4"
        let output = EngineResponse.Info(
            time: 1,
            multipv: 2,
            currmove: "e2e4",
            currmovenumber: 3,
            hashfull: 4.56,
            tbhits: 7,
            sbhits: 8,
            cpuload: 9,
            refutation: ["c7c5",
                         "d2d4"]
        )

        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .info(output)
        )
        XCTAssertEqual(
            EngineResponse(rawValue: input),
            .info(output)
        )
    }

    func testParseInfoWithInvalidScore() {
        let input = "info score test 5"
        let output = EngineResponse.Info(score: .init())

        XCTAssertEqual(
            EngineResponseParser.parse(response: input),
            .info(output)
        )
        XCTAssertEqual(
            EngineResponse(rawValue: input),
            .info(output)
        )
    }

}
