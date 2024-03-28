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
        case .stockfish:    return "15.1"
        case .lc0:          return "0.29"
        }
    }
    
    /// Engine-specific options to configure at initialization.
    var setupCommands: [EngineCommand] {
        switch self {
        case .stockfish:
            [
                .setoption(id: "Use NNUE", value: "false"),
                .setoption(id: "UCI_AnalyseMode", value: "true")
            ]
        case .lc0:
            []
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
