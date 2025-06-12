//
//  EngineResponseParserTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import Testing

struct EngineResponseParserTests {

  @Test func invalidResponse() {
    let invalid = "invalidcommand test"
    #expect(EngineResponseParser.parse(response: invalid) == nil)
    #expect(EngineResponse(rawValue: invalid) == nil)

    let empty = ""
    #expect(EngineResponseParser.parse(response: empty) == nil)
    #expect(EngineResponse(rawValue: empty) == nil)
  }

  @Test func parseID() {
    let inputName = "id name Engine Name"
    #expect(
      EngineResponseParser.parse(response: inputName) == .id(.name("Engine Name"))
    )
    #expect(
      EngineResponse(rawValue: inputName) == .id(.name("Engine Name"))
    )

    let inputAuthor = "id author Engine Author"
    #expect(
      EngineResponseParser.parse(response: inputAuthor) == .id(.author(("Engine Author")))
    )
    #expect(
      EngineResponse(rawValue: inputAuthor) == .id(.author(("Engine Author")))
    )

    let idInvalid = "id invalid input"
    #expect(EngineResponseParser.parse(response: idInvalid) == nil)
    #expect(EngineResponse(rawValue: idInvalid) == nil)
  }

  @Test func parseUciok() {
    let input = "uciok"
    #expect(
      EngineResponseParser.parse(response: input) == .uciok
    )
    #expect(
      EngineResponse(rawValue: input) == .uciok
    )
  }

  @Test func parseReadyok() {
    let input = "readyok"
    #expect(
      EngineResponseParser.parse(response: input) == .readyok
    )
    #expect(
      EngineResponse(rawValue: input) == .readyok
    )
  }

  @Test func parseBestMove() {
    let inputBestMove = "bestmove e2e4"
    #expect(
      EngineResponseParser.parse(response: inputBestMove) == .bestmove(move: "e2e4", ponder: nil)
    )
    #expect(
      EngineResponse(rawValue: inputBestMove) == .bestmove(move: "e2e4", ponder: nil)
    )

    let inputPonder = "bestmove e2e4 ponder e7e5"
    #expect(
      EngineResponseParser.parse(response: inputPonder) == .bestmove(move: "e2e4", ponder: "e7e5")
    )
    #expect(
      EngineResponse(rawValue: inputPonder) == .bestmove(move: "e2e4", ponder: "e7e5")
    )

    let inputBestMoveWithNewline1 = "bestmove\nc8d7 ponder e1c1"
    #expect(
      EngineResponse(rawValue: inputBestMoveWithNewline1) == .bestmove(move: "c8d7", ponder: "e1c1")
    )

    let inputBestMoveWithNewline2 = "bestmove \nc8d7 ponder e1c1"
    #expect(
      EngineResponse(rawValue: inputBestMoveWithNewline2) == .bestmove(move: "c8d7", ponder: "e1c1")
    )

    let bestMoveInvalid = "bestmove"
    #expect(EngineResponseParser.parse(response: bestMoveInvalid) == nil)
    #expect(EngineResponse(rawValue: bestMoveInvalid) == nil)
  }

  @Test func parseInfo() {
    let input =
      "info depth 1 seldepth 0 score cp 8.37 mate -4 upperbound pv e2e4 e7e5 g1f3 nodes 10 currline 4 d2d4 g8f6 c2c4 e7e6 nps 8 string This is a test string with real tokens inserted such as pv and nodes and score lowerbound."
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

    #expect(EngineResponseParser.parse(response: input) == .info(output))
    #expect(EngineResponse(rawValue: input) == .info(output))
  }

  @Test func parseExtraInfo() {
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
      refutation: [
        "c7c5",
        "d2d4"
      ]
    )

    #expect(EngineResponseParser.parse(response: input) == .info(output))
    #expect(EngineResponse(rawValue: input) == .info(output))
  }

  @Test func parseInfoWithInvalidScore() {
    let input = "info score test 5"
    let output = EngineResponse.Info(score: .init())

    #expect(EngineResponseParser.parse(response: input) == .info(output))
    #expect(EngineResponse(rawValue: input) == .info(output))
  }

}
