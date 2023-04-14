//
//  EngineType+.swift
//  ChessKitEngine
//

import ChessKitEngine_ObjC

extension EngineType {
    
    /// The user-readable name of the engine.
    public var name: String {
        switch self {
        case .stockfish:    return "Stockfish"
        @unknown default:   return "Unknown"
        }
    }
    
    /// The current version of the given engine.
    public var version: String {
        switch self {
        case .stockfish:    return "15.1"
        @unknown default:   return ""
        }
    }
    
}

// MARK: - CaseIterable

extension EngineType: CaseIterable {
    
    public static var allCases: [EngineType] {
        [.stockfish]
    }
    
}

// MARK: - Equatable

extension EngineType: Equatable {
    
}

// MARK: - Identifiable

extension EngineType: Identifiable {
    
    public var id: Self { self }
    
}
