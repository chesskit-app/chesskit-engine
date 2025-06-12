//
//  StockfishTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import XCTest

final class StockfishTests: BaseEngineTests {

  override func setUp() {
    engineType = .stockfish
    super.setUp()
  }

}
