//
//  EngineSetupLoop.swift
//  ChessKitEngine
//

protocol EngineSetupLoop {
    func nextCommand(given response: EngineResponse?) -> EngineCommand?
    var startupDidComplete: () -> Void { get set }
}

struct DefaultEngineSetupLoop: EngineSetupLoop {

    var startupDidComplete: () -> Void = {}

    func nextCommand(given response: EngineResponse?) -> EngineCommand? {
        // engine setup loop
        // <uci> → <uciok> → <isready> → <readok> → complete

        switch response {
        case nil:
            return .uci
        case .uciok:
            return .isready
        case .readyok:
            startupDidComplete()
            return nil
        default:
            return nil
        }
    }

}
