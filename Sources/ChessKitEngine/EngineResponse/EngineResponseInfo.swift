//
//  EngineResponse+Types.swift
//  ChessKitEngine
//

// MARK: - Info

public extension EngineResponse {

    struct Info  {
        public var depth: Int?
        public var seldepth: Int?
        public var time: Int?
        public var nodes: Int?
        public var pv: [String]?
        public var multipv: Int?
        public var score: Score?
        public var currmove: String?
        public var currmovenumber: Int?
        public var hashfull: Double?
        public var nps: Int?
        public var tbhits: Int?
        public var sbhits: Int?
        public var cpuload: Int?
        public var string: String?
        public var refutation: [String]?
        public var currline: CurrLine?

        /// Possible arguments for the `<info>` command.
        enum Argument: String, CaseIterable {
            case depth
            case seldepth
            case time
            case nodes
            case pv
            case multipv
            case score
            case currmove
            case currmovenumber
            case hashfull
            case nps
            case tbhits
            case sbhits
            case cpuload
            case string
            case refutation
            case currline

            enum ArgType {
                /// Single token follows the argument.
                case single
                /// Multiple tokens may follow the argument.
                case multi
                /// All remaining tokens should be concatenated following
                /// this argument.
                case string
                /// The argument is of type `EngineResponse.Score`.
                case score
                /// The argument is of type `(Int, [String])`
                case currentLine
            }

            var type: ArgType {
                switch self {
                case .depth:            return .single
                case .seldepth:         return .single
                case .time:             return .single
                case .nodes:            return .single
                case .pv:               return .multi
                case .multipv:          return .single
                case .score:            return .score
                case .currmove:         return .single
                case .currmovenumber:   return .single
                case .hashfull:         return .single
                case .nps:              return .single
                case .tbhits:           return .single
                case .sbhits:           return .single
                case .cpuload:          return .single
                case .string:           return .string
                case .refutation:       return .multi
                case .currline:         return .currentLine
                }
            }
        }

        /// Allows subscript access to `Info` properties
        /// to allow for easier `String` parsing.
        subscript(arg: String) -> Any? {
            get {
                guard let arg = Argument(rawValue: arg) else { return nil }

                switch arg {
                case .depth:           return depth
                case .seldepth:        return seldepth
                case .time:            return time
                case .nodes:           return nodes
                case .pv:              return pv
                case .multipv:         return multipv
                case .score:           return score
                case .currmove:        return currmove
                case .currmovenumber:  return currmovenumber
                case .hashfull:        return hashfull
                case .nps:             return nps
                case .tbhits:          return tbhits
                case .sbhits:          return sbhits
                case .cpuload:         return cpuload
                case .string:          return string
                case .refutation:      return refutation
                case .currline:        return currline
                }
            }
            set {
                guard let arg = Argument(rawValue: arg) else { return }

                switch arg {
                case .depth:           depth = newValue as? Int
                case .seldepth:        seldepth = newValue as? Int
                case .time:            time = newValue as? Int
                case .nodes:           nodes = newValue as? Int
                case .pv:              pv = newValue as? [String]
                case .multipv:         multipv = newValue as? Int
                case .score:           score = newValue as? Score
                case .currmove:        currmove = newValue as? String
                case .currmovenumber:  currmovenumber = newValue as? Int
                case .hashfull:        hashfull = newValue as? Double
                case .nps:             nps = newValue as? Int
                case .tbhits:          tbhits = newValue as? Int
                case .sbhits:          sbhits = newValue as? Int
                case .cpuload:         cpuload = newValue as? Int
                case .string:          string = newValue as? String
                case .refutation:      refutation = newValue as? [String]
                case .currline:        currline = newValue as? CurrLine
                }
            }
        }
    }

}

extension EngineResponse.Info: Equatable {}

extension EngineResponse.Info: CustomStringConvertible {
    public var description: String {
        var result = ""

        if let depth = depth {
            result += " <depth> \(depth)"
        }

        if let seldepth = seldepth {
            result += " <seldepth> \(seldepth)"
        }

        if let time = time {
            result += " <time> \(time)"
        }

        if let nodes = nodes {
            result += " <nodes> \(nodes)"
        }

        if let pv = pv, !pv.isEmpty {
            result += " <pv> \(pv.joined(separator: " "))"
        }

        if let multipv = multipv {
            result += " <multipv> \(multipv)"
        }

        if let score = score {
            result += " <score>\(score)"
        }

        if let currmove = currmove {
            result += " <currmove> \(currmove)"
        }

        if let currmovenumber = currmovenumber {
            result += " <currmovenumber> \(currmovenumber)"
        }

        if let hashfull = hashfull {
            result += " <hashfull> \(hashfull)"
        }

        if let nps = nps {
            result += " <nps> \(nps)"
        }

        if let tbhits = tbhits {
            result += " <tbhits> \(tbhits)"
        }

        if let sbhits = sbhits {
            result += " <sbhits> \(sbhits)"
        }

        if let cpuload = cpuload {
            result += " <cpuload> \(cpuload)"
        }

        if let string = string {
            result += " <string> \(string)"
        }

        if let refutation = refutation {
            result += " <refutation> \(refutation.joined(separator: " "))"
        }

        if let currline = currline {
            result += " <currline>\(currline)"
        }

        return result
    }
}

// MARK: - Score

public extension EngineResponse.Info {
    struct Score {
        /// The score from the engine's point of view in centipawns.
        public var cp: Double?
        /// Mate in moves, not plies.
        ///
        /// If the engine is getting mated use negative values.
        public var mate: Int?
        /// The score is just a lower bound.
        public var lowerbound: Bool?
        /// The score is just an upper bound.
        public var upperbound: Bool?

        /// Allows subscript access to `Score` properties
        /// to allow for easier `String` parsing.
        subscript(member: String) -> Any? {
            get {
                switch member {
                case "cp":          return cp
                case "mate":        return mate
                case "lowerbound":  return lowerbound
                case "upperbound":  return upperbound
                default:            return nil
                }
            }
            set {
                switch member {
                case "cp":          cp = newValue as? Double
                case "mate":        mate = newValue as? Int
                case "lowerbound":  lowerbound = newValue as? Bool
                case "upperbound":  upperbound = newValue as? Bool
                default:            return
                }
            }
        }
    }

}

extension EngineResponse.Info.Score: CustomStringConvertible {
    public var description: String {
        var result = ""

        if let cp = cp {
            result += " <cp> \(cp)"
        }

        if let mate = mate {
            result += " <mate> \(mate)"
        }

        if let lowerbound = lowerbound, lowerbound {
            result += " <lowerbound>"
        }

        if let upperbound = upperbound, upperbound {
            result += " <upperbound>"
        }

        return result
    }
}

extension EngineResponse.Info.Score: Equatable {}

// MARK: - CurrLine

extension EngineResponse.Info {
    public struct CurrLine {
        var cpunr: Int?
        var moves: [String]
    }
}

extension EngineResponse.Info.CurrLine: CustomStringConvertible {
    public var description: String {
        var result = ""

        if let cpunr = cpunr {
            result += " \(cpunr)"
        }

        if !moves.isEmpty {
            result += " \(moves.joined(separator: " "))"
        }

        return result
    }
}

extension EngineResponse.Info.CurrLine: Equatable {}
