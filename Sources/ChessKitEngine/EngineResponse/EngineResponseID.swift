//
//  EngineResponseID.swift
//  ChessKitEngine
//

public extension EngineResponse {

  /// Possible ID types that can be returned by
  /// `EngineResponse.id`.
  enum ID: Sendable {
    /// The engine's name.
    case name(String)
    /// The engine's author(s).
    case author(String)
  }

}
