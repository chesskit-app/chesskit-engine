//
//  EngineResponseInfoTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import Testing

struct EngineResponseInfoTests {

  @Test func subscripts() {
    #expect(sampleInput["depth"] as? Int == sampleInput.depth)
    #expect(sampleInput["seldepth"] as? Int == sampleInput.seldepth)
    #expect(sampleInput["time"] as? Int == sampleInput.time)
    #expect(sampleInput["nodes"] as? Int == sampleInput.nodes)
    #expect(sampleInput["pv"] as? [String] == sampleInput.pv)
    #expect(sampleInput["multipv"] as? Int == sampleInput.multipv)
    #expect(sampleInput["score"] as? EngineResponse.Info.Score == sampleInput.score)
    #expect(sampleInput["currmove"] as? String == sampleInput.currmove)
    #expect(sampleInput["currmovenumber"] as? Int == sampleInput.currmovenumber)
    #expect(sampleInput["hashfull"] as? Double == sampleInput.hashfull)
    #expect(sampleInput["nps"] as? Int == sampleInput.nps)
    #expect(sampleInput["tbhits"] as? Int == sampleInput.tbhits)
    #expect(sampleInput["sbhits"] as? Int == sampleInput.sbhits)
    #expect(sampleInput["cpuload"] as? Int == sampleInput.cpuload)
    #expect(sampleInput["string"] as? String == sampleInput.string)
    #expect(sampleInput["refutation"] as? [String] == sampleInput.refutation)
    #expect(sampleInput["currline"] as? EngineResponse.Info.CurrLine == sampleInput.currline)

  }

  @Test func stringConversion() {
    let output =
      " <depth> 1 <seldepth> 0 <time> 1 <nodes> 10 <pv> e2e4 e7e5 g1f3 <multipv> 2 <score> <cp> 8.37 <mate> -4 <upperbound> <currmove> e2e4 <currmovenumber> 3 <hashfull> 4.56 <nps> 8 <tbhits> 7 <sbhits> 8 <cpuload> 9 <string> This is a test string with real tokens inserted such as pv and nodes and score lowerbound. <refutation> c7c5 d2d4 <currline> 4 d2d4 g8f6 c2c4 e7e6"

    #expect(String(describing: sampleInput) == output)
  }

}

private extension EngineResponseInfoTests {
  var sampleInput: EngineResponse.Info {
    EngineResponse.Info(
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
  }
}
