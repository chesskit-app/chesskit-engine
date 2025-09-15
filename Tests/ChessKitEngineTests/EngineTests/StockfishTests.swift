//
//  StockfishTests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import XCTest

final class StockfishTests: BaseEngineTests {

  override func setUp() async throws {
    engineType = .stockfish
    try await super.setUp()
  }

}
