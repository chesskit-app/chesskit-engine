//
//  EngineType+.swift
//  ChessKitEngine
//

import ChessKitEngineCore

/// Possible engines available in `ChessKitEngine`.
public enum EngineType: Int {

    case stockfish
    case lc0

    /// Internal mapping from Swift to Obj-C type.
    var objc: EngineType_objc {
        switch self {
        case .stockfish:    return .stockfish
        case .lc0:          return .lc0
        }
    }

    /// The user-readable name of the engine.
    public var name: String {
        switch self {
        case .stockfish:    return "Stockfish"
        case .lc0:          return "LeelaChessZero (Lc0)"
        }
    }

    /// The current version of the given engine.
    public var version: String {
        switch self {
        case .stockfish:    return "16.1"
        case .lc0:          return "0.30"
        }
    }

    /// Engine-specific options to configure at initialization.
    var setupCommands: [EngineCommand] {
        switch self {
        case .stockfish:
            let fileOptions = [
                "EvalFile": "nn-b1a57edbea57",
                "EvalFileSmall": "nn-baff1ede1f90"
            ].compactMapValues {
                Bundle.main.url(forResource: $0, withExtension: "nnue")?.path()
            }

            return fileOptions.map(EngineCommand.setoption)
        case .lc0:
            let fileOptions = [
                "WeightsFile": "192x15_network"
            ].compactMapValues {
                Bundle.main.url(forResource: $0, withExtension: nil)?.path()
            }

            return fileOptions.map(EngineCommand.setoption)
        }
    }

}

// MARK: - CaseIterable

extension EngineType: CaseIterable {

}

// MARK: - Equatable

extension EngineType: Equatable {

}

// MARK: - Identifiable

extension EngineType: Identifiable {

    public var id: Self { self }

}
