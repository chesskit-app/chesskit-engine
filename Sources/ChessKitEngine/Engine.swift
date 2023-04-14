//
//  Engine.swift
//  ChessKitEngine
//

import ChessKitEngine_ObjC

public class Engine {
    
    /// Messenger used to communicate with engine.
    private let messenger: EngineMessenger
    
    /// Whether logging should be enabled.
    ///
    /// If set to `true`, engine commands and responses
    /// will be logged to the console. The default value is
    /// `false`.
    public var loggingEnabled = true
    
    /// Whether the engine is currently running.
    ///
    /// - To start the engine, call `start()`.
    /// - To stop the engine, call `stop()`.
    ///
    /// Engine must be running for `send(command:)` to work.
    public private(set) var isRunning = false
    
    /// Initializes an engine with the provided `type`.
    ///
    /// - parameter type: The type of engine to use. The
    /// default is `.stockfish` which corresponds to the latest
    /// supported Stockfish version.
    ///
    public init(type: EngineType = .stockfish) {
        messenger = EngineMessenger(engineType: type.objc)
        messenger.delegate = self
    }
    
    deinit {
        stop()
    }
    
    /// Starts the engine.
    ///
    /// - parameter coreCount: The number of processor cores to use for engine
    /// calculation. The default value is `nil` which uses the number of
    /// cores available on the device.
    ///
    /// This must be called before sending any commands
    /// with `send(command:)`.
    public func start(coreCount: Int? = nil, multipv: Int = 1) {
        messenger.start()
        isRunning = true
        
        // set UCI mode
        send(command: .uci)
        
        // configure engine options
        send(command: .setoption(id: "UCI_AnalyseMode", value: "true"))
        send(command: .setoption(
            id: "Threads",
            value: "\(max((coreCount ?? ProcessInfo.processInfo.processorCount) - 1, 1))"
        ))
        send(command: .setoption(id: "MultiPV", value: "\(multipv)"))
        
        // start analyzing
        send(command: .isready)
        send(command: .ucinewgame)
    }
    
    /// Stops the engine.
    ///
    /// Call this to stop all engine calculation and clean up.
    /// After calling `stop()`, `start()` must be called before
    /// sending any more commands with `send(command:)`.
    public func stop() {
        guard isRunning else { return }
        
        send(command: .stop)
        send(command: .quit)
        messenger.stop()
        
        isRunning = false
    }
    
    /// Sends a command to the engine.
    ///
    /// - parameter command: The command to send.
    ///
    /// Commands must be of type `EngineCommand` to ensure
    /// validity. While the engine is processing commands or
    /// thinking, any responses will be returned via `receiveResponse`.
    public func send(command: EngineCommand) {
        guard isRunning else {
            log("Engine is not running, call start() first.")
            return
        }
        
        log(command.rawValue)
        messenger.sendCommand(command.rawValue)
    }
    
    /// Closure that is called when engine responses are received.
    ///
    /// - parameter response: The response received from the engine.
    ///
    /// The returned `response` is of type `EngineResponse` which
    /// is a type-safe enum corresponding to the UCI protocol.
    public var receiveResponse: (_ response: EngineResponse) -> Void = {
        _ in
    }
    
}

// MARK: - Private

extension Engine {
    
    private func log(_ message: String) {
        if loggingEnabled {
            Logging.print(message)
        }
    }
    
}

// MARK: - EngineMessengerDelegate

extension Engine: EngineMessengerDelegate {
    public func messenger(
        _ messenger: EngineMessenger,
        didReceiveResponse response: String
    ) {
        if let parsedResponse = EngineResponse(rawValue: response) {
            log(parsedResponse.rawValue)
            receiveResponse(parsedResponse)
        } else if !response.isEmpty {
            log(response)
        }
    }
}
