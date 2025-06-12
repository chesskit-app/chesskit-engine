//
//  EngineResponseParser.swift
//  ChessKitEngine
//

enum EngineResponseParser {

  static func parse(response: String) -> EngineResponse? {
    let tokens = response.split { $0.isWhitespace || $0.isNewline }.map(String.init)
    var iterator = tokens.makeIterator()

    guard let command = iterator.next() else {
      return nil
    }

    switch command {
    case "id": return parseID(&iterator)
    case "uciok": return .uciok
    case "readyok": return .readyok
    case "bestmove": return parseBestMove(&iterator)
    case "info": return parseInfo(&iterator)
    default: return nil
    }
  }

  // MARK: - Private

  private static func parseID(_ iterator: inout IndexingIterator<[String]>) -> EngineResponse? {
    switch iterator.next() {
    case "name": return .id(.name(iterator.joined(separator: " ")))
    case "author": return .id(.author(iterator.joined(separator: " ")))
    default: return nil
    }
  }

  private static func parseBestMove(_ iterator: inout IndexingIterator<[String]>) -> EngineResponse? {
    guard let move = iterator.next() else { return nil }

    var ponder: String?
    if iterator.next() == "ponder" {
      ponder = iterator.next()
    }

    return .bestmove(move: move, ponder: ponder)
  }

  private static func parseInfo(_ iterator: inout IndexingIterator<[String]>) -> EngineResponse? {
    let arguments = EngineResponse.Info.Argument.allCases
    // possible sub-arguments for <score> argument
    let scoreSubArguments = ["cp", "mate"]

    var info = EngineResponse.Info()
    var score: EngineResponse.Info.Score?
    var currLine: EngineResponse.Info.CurrLine?

    var activeArg: String?
    var activeScoreSubArg: String?
    var multiArgCollection: [String] = []

    var token = iterator.next()

    while token != nil {

      if let token,
        activeArg == nil,
        arguments.map(\.rawValue).contains(token)
      {

        activeArg = token

      } else if let token,
        let active = activeArg,
        arguments.map(\.rawValue).contains(token)
      {

        // A new valid argument has been reached,
        // set "in progress" structures accordingly
        // and clean up / reset
        if !multiArgCollection.isEmpty {
          info[active] = map(multiArgCollection, for: active)
          multiArgCollection = []
        }

        if currLine != nil {
          info[active] = map(currLine, for: active)
          currLine = nil
        }

        if score != nil {
          info[active] = map(score, for: active)
          score = nil
        }

        // Set active argument to the new token
        activeArg = token

      } else if let active = activeArg, let token {
        if let type = EngineResponse.Info.Argument(rawValue: active)?.type {
          switch type {
          case .single:
            info[active] = map(token, for: active)
            activeArg = nil
          case .multi:
            multiArgCollection.append(token)
          case .string:
            var stringTokens = [token]
            var subtoken = iterator.next()

            // consume rest of iterator for `string`
            while subtoken != nil {
              if let subtoken {
                stringTokens.append(subtoken)
              }

              subtoken = iterator.next()
            }

            info[active] = stringTokens.joined(separator: " ")
          case .score:
            if score == nil {
              score = .init()
            }

            if ["lowerbound", "upperbound"].contains(token) {
              score?[token] = true
            }

            if scoreSubArguments.contains(token) {
              activeScoreSubArg = token
            } else if let activeScore = activeScoreSubArg {
              switch activeScore {
              case "cp":
                score?[activeScore] = Double(token)
              case "mate":
                score?[activeScore] = Int(token)
              default:
                break
              }

              activeScoreSubArg = nil
            }
          case .currentLine:
            if currLine?.cpunr == nil {
              currLine = .init(moves: [])
              currLine?.cpunr = Int(token)
            } else {
              currLine?.moves.append(token)
            }
          }
        }
      }

      token = iterator.next()
    }

    // populate any "in progress" structures that
    // did not have a chance to be added to `info`
    if let activeArg {
      if !multiArgCollection.isEmpty {
        info[activeArg] = map(multiArgCollection, for: activeArg)
      }

      if currLine != nil {
        info[activeArg] = map(currLine, for: activeArg)
      }

      if score != nil {
        info[activeArg] = map(score, for: activeArg)
      }
    }

    return .info(info)
  }

  /// Maps `value` to appropriate type depending on `key`.
  private static func map(_ value: Any?, for key: String) -> Any? {
    guard let argument = EngineResponse.Info.Argument(rawValue: key),
      let value
    else {
      return nil
    }

    switch argument {
    case .depth: return Int(value as? String ?? "")
    case .seldepth: return Int(value as? String ?? "")
    case .time: return Int(value as? String ?? "")
    case .nodes: return Int(value as? String ?? "")
    case .pv: return value as? [String]
    case .multipv: return Int(value as? String ?? "")
    case .score: return value as? EngineResponse.Info.Score
    case .currmove: return value as? String
    case .currmovenumber: return Int(value as? String ?? "")
    case .hashfull: return Double(value as? String ?? "")
    case .nps: return Int(value as? String ?? "")
    case .tbhits: return Int(value as? String ?? "")
    case .sbhits: return Int(value as? String ?? "")
    case .cpuload: return Int(value as? String ?? "")
    case .string: return value as? String
    case .refutation: return value as? [String]
    case .currline: return value as? EngineResponse.Info.CurrLine
    }
  }

}
