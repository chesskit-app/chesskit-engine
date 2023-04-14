//
//  EngineType+.swift
//  ChessKitEngine
//

import ChessKitEngine_ObjC

public enum EngineType: Int {
    
    case stockfish
    
    /// Internal mapping from Swift to Obj-C type.
    var objc: EngineType_ObjC {
        switch self {
        case .stockfish:    return .stockfish
        }
    }
    
    /// The user-readable name of the engine.
    public var name: String {
        switch self {
        case .stockfish:    return "Stockfish"
        }
    }
    
    /// The current version of the given engine.
    public var version: String {
        switch self {
        case .stockfish:    return "15.1"
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
