//
//  EngineResponseInfoTests.swift
//  ChessKitEngineTests
//

import XCTest
@testable import ChessKitEngine

class EngineResponseInfoTests: XCTestCase {
    
    func testStringConversion() {
        let input = ChessKitEngineResponse.Info(
            depth: 1,
            seldepth: 0,
            time: 1,
            nodes: 10,
            pv: ["e2e4", "e7e5", "g1f3"],
            multipv: 2,
            score: .init(
                cp: 8.37,
                mate: -4,
                upperbound: true
            ),
            currmove: "e2e4",
            currmovenumber: 3,
            hashfull: 4.56,
            nps: 8,
            tbhits: 7,
            sbhits: 8,
            cpuload: 9,
            string: "This is a test string with real tokens inserted such as pv and nodes and score lowerbound.",
            refutation: ["c7c5", "d2d4"],
            currline: .init(
                cpunr: 4,
                moves: ["d2d4", "g8f6", "c2c4", "e7e6"]
            )
        )
        
        let output = " <depth> 1 <seldepth> 0 <time> 1 <nodes> 10 <pv> e2e4 e7e5 g1f3 <multipv> 2 <score> <cp> 8.37 <mate> -4 <upperbound> <currmove> e2e4 <currmovenumber> 3 <hashfull> 4.56 <nps> 8 <tbhits> 7 <sbhits> 8 <cpuload> 9 <string> This is a test string with real tokens inserted such as pv and nodes and score lowerbound. <refutation> c7c5 d2d4 <currline> 4 d2d4 g8f6 c2c4 e7e6"
        
        XCTAssertEqual(String(describing: input), output)
    }
    
}
