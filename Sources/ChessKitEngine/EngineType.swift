//
//  EngineType+.swift
//  ChessKitEngine
//

import ChessKitEngineCore

/// Possible engines available in `ChessKitEngine`.
public enum EngineType: Int {
    
    case stockfish
    case lc0
    case arasan
    
    /// Internal mapping from Swift to Obj-C type.
    var objc: EngineType_objc {
        switch self {
        case .stockfish:    return .stockfish
        case .lc0:          return .lc0
        case .arasan:       return .arasan
        }
    }
    
    /// The user-readable name of the engine.
    public var name: String {
        switch self {
        case .stockfish:    return "Stockfish"
        case .lc0:          return "LeelaChessZero (Lc0)"
        case .arasan:        return "Arasan"
        }
    }
    
    /// The current version of the given engine.
    public var version: String {
        switch self {
        case .stockfish:    return "15.1"
        case .lc0:          return "0.29"
        case .arasan:       return "24.0.0"
        }
    }
    
    /// Engine-specific options to configure at initialization.
    var setupCommands: [EngineCommand] {
        switch self {
        case .stockfish:
            let evalFile = Bundle.module.url(forResource: "nn-1337b1adec5b", withExtension: "nnue")?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
            
            return [
                evalFile != nil ?
                    .setoption(id: "EvalFile", value: evalFile!) : nil,
                .setoption(id: "Use NNUE", value: "true"),
                .setoption(id: "UCI_AnalyseMode", value: "true")
            ].compactMap { $0 }
        case .lc0:
            let weights = Bundle.module.url(forResource: "192x15_network", withExtension: nil)?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
            
            return [
                .setoption(id: "Backend", value: "eigen"),
                weights != nil ?
                    .setoption(id: "WeightsFile", value: weights!) : nil
            ].compactMap { $0 }
        case .arasan:
            let openingBook = Bundle.module.url(forResource: "book", withExtension: "bin")?
                .absoluteString
                .replacingOccurrences(of: "file://", with: "")
                
            return [
                openingBook != nil ?
                    .setoption(id: "BookPath", value: openingBook!) : nil
            ].compactMap { $0 }
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
