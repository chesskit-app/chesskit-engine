//
//  EngineCommandTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import Testing

struct EngineCommandTests {

  @Test func debugCommand() {
    let debugOn = EngineCommand.debug(on: true)
    #expect(debugOn.rawValue == "debug on")

    let debugOff = EngineCommand.debug(on: false)
    #expect(debugOff.rawValue == "debug off")
  }

  @Test func uciCommand() {
    #expect(EngineCommand.uci.rawValue == "uci")
  }

  @Test func isReadyCommand() {
    #expect(EngineCommand.isready.rawValue == "isready")
  }

  @Test func setOptionCommand() {
    let setOption1 = EngineCommand.setoption(id: "name", value: "val")
    #expect(setOption1.rawValue == "setoption name name value val")

    let setOption2 = EngineCommand.setoption(id: "name")
    #expect(setOption2.rawValue == "setoption name name")
  }

  @Test func uciNewGameCommand() {
    #expect(EngineCommand.ucinewgame.rawValue == "ucinewgame")
  }

  @Test func positionCommand() {
    #expect(
      EngineCommand.position(
        .startpos,
        moves: ["e2e4", "c7c6"]
      ).rawValue == "position startpos moves e2e4 c7c6"
    )

    #expect(
      EngineCommand.position(
        .fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
      ).rawValue == "position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    )

    #expect(
      EngineCommand.position(
        .fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
        moves: ["e2e4", "c7c6"]
      ).rawValue == "position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 moves e2e4 c7c6"
    )
  }

  @Test func goCommand() {
    let go = EngineCommand.go(
      searchmoves: ["e2e4", "c7c6"],
      ponder: true,
      wtime: 5,
      btime: 5,
      winc: 2,
      binc: 2,
      movestogo: 10,
      depth: 15,
      nodes: 100,
      mate: 2,
      movetime: 3,
      infinite: false
    )

    #expect(go.rawValue == "go searchmoves e2e4 c7c6 ponder wtime 5 btime 5 winc 2 binc 2 movestogo 10 depth 15 nodes 100 mate 2 movetime 3")

    let goInfinite = EngineCommand.go(infinite: true)
    #expect(goInfinite.rawValue == "go infinite")
  }

  @Test func stopCommand() {
    #expect(EngineCommand.stop.rawValue == "stop")
  }

  @Test func ponderhitCommand() {
    #expect(EngineCommand.ponderhit.rawValue == "ponderhit")
  }

  @Test func quitCommand() {
    #expect(EngineCommand.quit.rawValue == "quit")
  }

}
