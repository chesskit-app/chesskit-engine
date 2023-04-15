//
//  EngineCommandTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

class EngineCommandTests: XCTestCase {
    
    func testDebugCommand() {
        let debugOn = EngineCommand.debug(on: true)
        XCTAssertEqual(debugOn.rawValue, "debug on")
        
        let debugOff = EngineCommand.debug(on: false)
        XCTAssertEqual(debugOff.rawValue, "debug off")
    }
    
    func testUciCommand() {
        XCTAssertEqual(EngineCommand.uci.rawValue, "uci")
    }
    
    func testIsReadyCommand() {
        XCTAssertEqual(EngineCommand.isready.rawValue, "isready")
    }
    
    func testSetOptionCommand() {
        let setOption1 = EngineCommand.setoption(id: "name", value: "val")
        XCTAssertEqual(
            setOption1.rawValue,
            "setoption name name value val"
        )
        
        let setOption2 = EngineCommand.setoption(id: "name")
        XCTAssertEqual(
            setOption2.rawValue,
            "setoption name name"
        )
    }
    
    func testUciNewGameCommand() {
        XCTAssertEqual(EngineCommand.ucinewgame.rawValue, "ucinewgame")
    }
    
    func testPositionCommand() {
        XCTAssertEqual(
            EngineCommand.position(
                .startpos,
                moves: ["e2e4", "c7c6"]
            ).rawValue,
            "position startpos moves e2e4 c7c6"
        )
        
        XCTAssertEqual(
            EngineCommand.position(
                .fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            ).rawValue,
            "position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        )
        
        XCTAssertEqual(
            EngineCommand.position(
                .fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
                moves: ["e2e4", "c7c6"]
            ).rawValue,
            "position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 moves e2e4 c7c6"
        )
    }
    
    func testGoCommand() {
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
        
        XCTAssertEqual(go.rawValue, "go searchmoves e2e4 c7c6 ponder wtime 5 btime 5 winc 2 binc 2 movestogo 10 depth 15 nodes 100 mate 2 movetime 3")
        
        let goInfinite = EngineCommand.go(infinite: true)
        XCTAssertEqual(goInfinite.rawValue, "go infinite")
    }
    
    func testStopCommand() {
        XCTAssertEqual(EngineCommand.stop.rawValue, "stop")
    }
    
    func testPonderhitCommand() {
        XCTAssertEqual(EngineCommand.ponderhit.rawValue, "ponderhit")
    }
    
    func testQuitCommand() {
        XCTAssertEqual(EngineCommand.quit.rawValue, "quit")
    }
    
}
