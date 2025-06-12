//
//  EngineCommandPositionTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import Testing

struct EngineCommandPositionTests {

  @Test func positionStringRawValue() {
    let p = EngineCommand.PositionString.startpos
    #expect(p.rawValue == "startpos")

    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    let f = EngineCommand.PositionString.fen(fen)
    #expect(f.rawValue == "fen \(fen)")
  }

  @Test func positionStringRawValueInit() {
    #expect(EngineCommand.PositionString(rawValue: "startpos") == .startpos)

    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen)") == .fen(fen))
  }

  @Test func invalidFENPositionStrings() {
    let fen1 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen1)") == nil)

    let fen2 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen2)") == nil)

    let fen3 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen3)") == nil)

    let fen4 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen4)") == nil)

    let fen5 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0"
    #expect(EngineCommand.PositionString(rawValue: "fen \(fen5)") == nil)
  }

  @Test func invalidPositionString() {
    #expect(EngineCommand.PositionString(rawValue: "invalid") == nil)
    #expect(EngineCommand.PositionString(rawValue: "") == nil)
  }

}
