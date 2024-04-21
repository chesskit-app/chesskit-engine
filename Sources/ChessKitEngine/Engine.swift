//
//  Engine.swift
//  ChessKitEngine
//

import ChessKitEngineCore

public class Engine {

    /// The type of the engine.
    private let type: EngineType

    /// Messenger used to communicate with engine.
    private let messenger: EngineMessenger

    /// Whether logging should be enabled.
    ///
    /// If set to `true`, engine commands and responses
    /// will be logged to the console. The default value is
    /// `false`.
    public var loggingEnabled = false

    /// Whether the engine is currently running.
    ///
    /// - To start the engine, call `start()`.
    /// - To stop the engine, call `stop()`.
    ///
    /// Engine must be running for `send(command:)` to work.
    public private(set) var isRunning = false

    private let queue = DispatchQueue(
        label: "ck-engine-queue",
        qos: .userInteractive
    )

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
    /// - parameter completion: The completion handler that is called when
    /// the engine set up is complete. You must wait for this to be called
    /// before sending further commands to the engine.
    ///
    /// This must be called before sending any commands
    /// with `send(command:)`.
    public func start(coreCount: Int? = nil, multipv: Int = 1, completion: @escaping () -> Void) {
        messenger.responseHandler = { [weak self] response in
            guard let self else { return }

            Task { @MainActor in
                if let parsedResponse = EngineResponse(rawValue: response) {
                    self.log(parsedResponse.rawValue)

                    if parsedResponse == .uciok && !self.isRunning {
                        self.send(command: .isready)
                        return
                    }

                    if parsedResponse == .readyok && !self.isRunning {
                        self.isRunning = true
                        self.performInitialSetup(
                            coreCount: coreCount ?? ProcessInfo.processInfo.processorCount,
                            multipv: multipv
                        )
                        completion()
                        return
                    }

                    self.receiveResponse(parsedResponse)
                } else if !response.isEmpty {
                    self.log(response)
                }
            }
        }

        messenger.start()

        // set UCI mode
        send(command: .uci)
    }

    private var initialSetupComplete = false

    private func performInitialSetup(coreCount: Int, multipv: Int) {
        guard !initialSetupComplete else { return }

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
            self.log(command.rawValue)
            self.messenger.sendCommand(command.rawValue)
        }
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
