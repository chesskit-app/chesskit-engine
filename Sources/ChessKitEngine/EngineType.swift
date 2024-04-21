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
        case .lc0:          return "0.29"
        }
    }

    /// Engine-specific options to configure at initialization.
    var setupCommands: [EngineCommand] {
        switch self {
        case .stockfish:
            let evalFiles = ["nn-baff1ede1f90", "nn-b1a57edbea57"]
                .map {
                    Bundle.main.url(forResource: $0, withExtension: "nnue")?
                        .absoluteString
                        .replacingOccurrences(of: "file://", with: "")
                }

            if let smallFileURL = evalFiles[0], let bigFileURL = evalFiles[1] {
                return [
                    .setoption(id: "EvalFile", value: bigFileURL),
                    .setoption(id: "EvalFileSmall", value: smallFileURL)
                ]
            } else {
                return []
            }
        case .lc0:
            return []
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
