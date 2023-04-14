//
//  EngineResponse.swift
//  ChessKitEngine
//

/// Possible engine responses based on the
/// [Universal Chess Interface (UCI)](https://backscattering.de/chess/uci/2006-04.txt).
///
public enum EngineResponse {
    
    /// `"id name <x>"`, `"id author <x>"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case id(ID)
    
    /// `"uciok"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case uciok
    
    /// `"readyok"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case readyok
    
    /// `"bestmove <move1> [ ponder <move2> ]"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case bestmove(move: String, ponder: String?)
    
    /// `"info"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case info(Info)
    
}

extension EngineResponse: Equatable {}

extension EngineResponse: RawRepresentable {
    public init?(rawValue: String) {
        let parsed = EngineResponseParser.parse(response: rawValue)
        
        guard let parsed else {
            return nil
        }
        
        self = parsed
    }
    
    public var rawValue: String {
        switch self {
        case let .id(id):
            switch id {
            case let .name(name):
                return "<id> <name> \(name)"
            case let .author(author):
                return "<id> <author> \(author)"
            }
        case .uciok:
            return "<uciok>"
        case .readyok:
            return "<readyok>"
        case let .bestmove(move, ponder):
            if let ponder {
                return "<bestmove> \(move) <ponder> \(ponder)"
            } else {
                return "<bestmove> \(move)"
            }
        case let .info(info):
            return "<info>\(info)"
        }
    }
}
