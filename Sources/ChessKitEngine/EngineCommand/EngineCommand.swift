//
//  EngineCommand.swift
//  ChessKitEngine
//

/// Possible engine commands based on the
/// [Universal Chess Interface (UCI)](https://backscattering.de/chess/uci/2006-04.txt).
///
public enum EngineCommand: Equatable {
    
    /// `"debug [ on | off ]"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case debug(on: Bool)
    
    /// `"uci"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case uci
    
    /// `"isready"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case isready
    
    /// `"setoption name <id> [value <x>]"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case setoption(id: String, value: String? = nil)
    
    /// `"ucinewgame"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case ucinewgame
    
    /// `"position [fen <fenstring> | startpos ]  moves <move1> .... <movei>"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case position(PositionString, moves: [String]? = nil)
    
    /// `"go"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case go(
        searchmoves: [String]? = nil, ponder: Bool = false,
        wtime: Int? = nil, btime: Int? = nil,
        winc: Int? = nil, binc: Int? = nil,
        movestogo: Int? = nil, depth: Int? = nil,
        nodes: Int? = nil, mate: Int? = nil,
        movetime: Int? = nil, infinite: Bool = false
    )
    
    /// `"stop"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case stop
    
    /// `"ponderhit"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case ponderhit
    
    /// `"quit"`
    ///
    /// See [UCI protocol documentation](https://backscattering.de/chess/uci/2006-04.txt)
    /// for more information.
    case quit
    
    /// Produces the raw engine-readable string for the given command.
    var rawValue: String {
        switch self {
        case let .debug(on):
            return "debug \(on ? "on" : "off")"
        case .uci:
            return "uci"
        case .isready:
            return "isready"
        case let .setoption(id, value):
            var result =  "setoption name \(id)"
            
            if let value {
                result += " value \(value)"
            }
            
            return result
        case .ucinewgame:
            return "ucinewgame"
        case let .position(position, moves):
            var result = "position \(position.rawValue)"
            
            if let moves, !moves.isEmpty {
                result += " moves \(moves.joined(separator: " "))"
            }
            
            return result
        case let .go(
            searchmoves, ponder, wtime, btime, winc, binc,
            movestogo, depth, nodes, mate, movetime, infinite
        ):
            var result = "go"
            
            if let searchmoves, !searchmoves.isEmpty {
                result += " searchmoves \(searchmoves.joined(separator: " "))"
            }
            
            if ponder {
                result += " ponder"
            }
            
            if let wtime {
                result += " wtime \(wtime)"
            }
            
            if let btime {
                result += " btime \(btime)"
            }
            
            if let winc {
                result += " winc \(winc)"
            }
            
            if let binc {
                result += " binc \(binc)"
            }
            
            if let movestogo {
                result += " movestogo \(movestogo)"
            }
            
            if let depth {
                result += " depth \(depth)"
            }
            
            if let nodes {
                result += " nodes \(nodes)"
            }
            
            if let mate {
                result += " mate \(mate)"
            }
            
            if let movetime {
                result += " movetime \(movetime)"
            }
            
            if infinite {
                result += " infinite"
            }
            
            return result
        case .stop:
            return "stop"
        case .ponderhit:
            return "ponderhit"
        case .quit:
            return "quit"
        }
    }
}
