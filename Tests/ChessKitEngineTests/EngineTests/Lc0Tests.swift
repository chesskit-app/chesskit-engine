//
//  Lc0Tests.swift
//  ChessKitEngineTests
//

@testable import ChessKitEngine
import XCTest

final class Lc0Tests: BaseEngineTests {

  override func setUp() async throws {
    engineType = .lc0
    try await super.setUp()
  }

}
