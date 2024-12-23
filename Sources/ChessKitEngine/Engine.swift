//
//  Engine.swift
//  ChessKitEngine
//

import ChessKitEngineCore
import Combine

//private class EngineConfiguration {
//    
//}

public final class Engine {//}: Sendable {

    /// The type of the engine.
    public let type: EngineType

    /// Whether the engine is currently running.
    ///
    /// - To start the engine, call `start()`.
    /// - To stop the engine, call `stop()`.
    ///
    /// Engine must be running for `send(command:)` to work.
    public private(set) var isRunning = false
    
    /// Whether logging should be enabled.
    ///
    /// If set to `true`, engine commands and responses
    /// will be logged to the console. The default value is
    /// `false`.
    public var loggingEnabled = false
    
    /// Closure that is called when engine responses are received.
    ///
    /// - parameter response: The response received from the engine.
    ///
    /// The returned `response` is of type `EngineResponse` which
    /// is a type-safe enum corresponding to the UCI protocol.
    public var responsePublisher: PassthroughSubject<EngineResponse, Never>? = nil
    
    /// Messenger used to communicate with engine.
    private let messenger: EngineMessenger

    
    private let queue = DispatchQueue(
        label: "ck-engine-queue",
        qos: .userInteractive
    )
    
//    private var startupLoop = DefaultEngineSetupLoop()
    
    private var initialSetupComplete = false

    /// Initializes an engine with the provided `type`.
    ///
    /// - parameter type: The type of engine to use.
    ///
    public init(type: EngineType) {
        self.type = type
        messenger = EngineMessenger(engineType: type.objc)
    }

    deinit {
        stop()
    }

    /// Starts the engine.
    ///
    /// - parameter coreCount: The number of processor cores to use for engine
    /// calculation. The default value is `nil` which uses the number of
    /// cores available on the device.
    /// - parameter multipv: The number of lines the engine should return,
    /// sent via the `"MultiPV"` UCI option.
    ///
    /// - note You must call this function and wait for ``EngineResponse/readyok``
    /// before sending any commands with ``send(command:)``.
    public func start(
        coreCount: Int? = nil,
        multipv: Int = 1//,
//        completion: @escaping () -> Void = {}
    ) {
        messenger.responseHandler = { [weak self] response in
            guard let self else { return }

            guard let parsed = EngineResponse(rawValue: response) else {
                if !response.isEmpty {
                    log(response)
                }
                return
            }

            log(parsed.rawValue)

            if !isRunning {
                if parsed == .readyok {
                    performInitialSetup(
                        coreCount: coreCount ?? ProcessInfo.processInfo.processorCount,
                        multipv: multipv
                    )
                } else if let next = EngineCommand.nextSetupLoopCommand(given: parsed) {
                    send(command: next)
                }
            }
            
            responsePublisher?.send(parsed)
//            if self?.isRunning == false,
//                let next = self?.startupLoop.nextCommand(given: parsed) {
//                self?.send(command: next)
//            }
            
//            DispatchQueue.main.async {
//                self.receiveResponse(parsed)
//            }
        }

        messenger.start()

        // start engine setup loop
        send(command: .uci)
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
        initialSetupComplete = false
    }

    /// Sends a command to the engine.
    ///
    /// - parameter command: The command to send.
    ///
    /// Commands must be of type `EngineCommand` to ensure
    /// validity. While the engine is processing commands or
    /// thinking, any responses will be returned via `receiveResponse`.
    public func send(command: EngineCommand) {
        guard isRunning || [.uci, .isready].contains(command) else {
            log("Engine is not running, call start() first.")
            return
        }

        queue.sync {
            log(command.rawValue)
            messenger.sendCommand(command.rawValue)
        }
    }

    // MARK: - Private

    /// Logs `message` if `loggingEnabled` is `true`.
    private func log(_ message: String) {
        if loggingEnabled {
            Logging.print(message)
        }
    }
    
    /// Sets initial engine options.
    private func performInitialSetup(coreCount: Int, multipv: Int) {
        guard !initialSetupComplete else { return }
        
        isRunning = true

        // configure engine-specific options
        type.setupCommands.forEach(send)

        // configure common engine options
        send(command: .setoption(
            id: "Threads",
            value: "\(max(coreCount - 1, 1))"
        ))
        send(command: .setoption(id: "MultiPV", value: "\(multipv)"))

        initialSetupComplete = true
    }

}
