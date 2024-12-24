//
//  Engine.swift
//  ChessKitEngine
//

import ChessKitEngineCore
import AsyncAlgorithms

public final class Engine: Sendable {
    /// The type of the engine.
    public let type: EngineType

    /// Whether the engine is currently running.
    ///
    /// - To start the engine, call ``start()``.
    /// - To stop the engine, call ``stop()``.
    ///
    /// Engine must be running for `send(command:)` to work.
    public var isRunning: Bool {
        get async { await engineConfigurationActor.isRunning }
    }
    
    /// Whether logging should be enabled.
    ///
    /// If set to `true`, engine commands and responses
    /// will be logged to the console. The default value is
    /// `false`.
    ///
    ///  Can be set via ``setLoggingEnabled(_:)`` function.
    
    public var loggingEnabled: Bool {
        get async { await engineConfigurationActor.loggingEnabled }
    }
    
    /// AsyncChannel that is called when engine responses are received.
    ///
    /// - parameter response: The response received from the engine.
    ///
    /// The underlying value is of type ``EngineResponse`` which
    /// is a type-safe sendable enum corresponding to the UCI protocol.
    public var responseChannel : AsyncStream<EngineResponse>? {
        get async { await engineConfigurationActor.asyncStream }
    }
    
    private let engineConfigurationActor: EngineConfiguration
    
    /// Messenger used to communicate with engine.
    ///
    private let messenger: EngineMessenger
    
    private let queue = DispatchQueue(
        label: "ck-engine-queue",
        qos: .userInteractive
    )
        

    /// Initializes an engine with the provided `type`.
    ///
    /// - parameter type: The type of engine to use.
    /// - parameter loggingEnabled: If set to `true`, engine commands and responses
    ///   will be logged to the console. The default value is `false`.
    public init(type: EngineType, loggingEnabled: Bool = false) {
        self.type = type
        self.messenger = EngineMessenger(engineType: type.objc)
        self.engineConfigurationActor = EngineConfiguration(loggingEnabled: loggingEnabled)
    }


    // This no longer work in async environment as stop function outlives the deinit function.
    // Support for async deinit should be added in a future version of Swift (6.1)
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
    //    deinit {
    //        stop()
    //    }

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
        multipv: Int = 1
    ) {
        Task { @MainActor in
            await engineConfigurationActor.setAsyncStream()
            
            engineResponseAsync(coreCount: coreCount, multipv: multipv)

            messenger.start()

            // start engine setup loop
            await send(command: .uci)
        }
    }

    /// Stops the engine.
    ///
    /// Call this to stop all engine calculation and clean up.
    /// After calling ``stop()``, ``start()`` must be called before
    /// sending any more commands with ``send(command:)``.
    ///
    ///
    /// - note: as temporary fix this function must be called before deiniting the engine.
    public func stop() async {
        guard await isRunning == true else { return }
            
        await send(command: .stop)
        await send(command: .quit)
        messenger.stop()
            
            
        await engineConfigurationActor.setIsRunning(isRunning: false)
        await engineConfigurationActor
            .setInitialSetupComplete(initialSetupComplete: false)
        await engineConfigurationActor.streamContinuation?.finish()
    }

    /// Sends a command to the engine.
    ///
    /// - parameter command: The command to send.
    ///
    /// Commands must be of type ``EngineCommand`` to ensure
    /// validity. While the engine is processing commands or
    /// thinking, any responses will be returned via ``responseChannel``.
    public func send(command: EngineCommand) async {
        guard await isRunning || [.uci, .isready].contains(command) else {
            await log("Engine is not running, call start() first.")
            return
        }

        await log(command.rawValue)
        
        queue.sync {
            messenger.sendCommand(command.rawValue)
        }
    }
    
    public func setLoggingEnabled(_ enabled: Bool) {
        Task {
            await engineConfigurationActor
                .setLoggingEnabled(loggingEnabled: loggingEnabled)
        }
    }

    // MARK: - Private

    /// Logs `message` if `loggingEnabled` is `true`.
    private func log(_ message: String) async {
        if await loggingEnabled {
            Logging.print(message)
        }
    }
    
    /// convinience function to set up `messenger.responseHandler`
    private func engineResponseAsync(
        coreCount: Int? = nil,
        multipv: Int = 1
    ) {
        messenger.responseHandler = { [weak self] response in
            Task{ [weak self] in
                guard let self,
                      let parsed = EngineResponse(rawValue: response) else {
                    if !response.isEmpty {
                        await self?.log(response)
                    }
                    return
                }
                    
                await self.log(parsed.rawValue)
                    
                if await !self.isRunning {
                    if parsed == .readyok {
                        await self.performInitialSetup(
                            coreCount: coreCount ?? ProcessInfo.processInfo.processorCount,
                            multipv: multipv
                        )
                    } else if let next = EngineCommand.nextSetupLoopCommand(
                        given: parsed
                    ) {
                        await self.send(command: next)
                    }
                }
                await self.engineConfigurationActor.streamContinuation?.yield(parsed)
            }
        }
    }
    
    /// Sets initial engine options.
    private func performInitialSetup(coreCount: Int, multipv: Int) async {
        guard await !engineConfigurationActor.initialSetupComplete else { return }
        
        await engineConfigurationActor.setIsRunning(isRunning: true)

        // configure engine-specific options
        for command in type.setupCommands {
            await send(command: command)
        }

        // configure common engine options
        await send(command: .setoption(
            id: "Threads",
            value: "\(max(coreCount - 1, 1))"
        ))
        await send(command: .setoption(id: "MultiPV", value: "\(multipv)"))

        await engineConfigurationActor
            .setInitialSetupComplete(initialSetupComplete:  true)
    }

}

//An actor to hold the configuration for the engine class.
//Since engine now conforms to sendable protocol, we need to
//move the mutable data into async safe environment.
//
fileprivate actor EngineConfiguration: Sendable {
    /// Whether the engine is currently running.
    private(set) var isRunning = false
    
    /// Whether logging should be enabled.
    private(set) var loggingEnabled = false
    
    /// Whether the initial engine setup was completed
    private(set) var initialSetupComplete = false
    
    /// An async stream to notify the end user about engine responses
    private(set) var asyncStream: AsyncStream<EngineResponse>?
    
    /// A reference to AsyncStream's continuation for later access by `EngineMessenger.responseHandler`
    private(set) var streamContinuation: AsyncStream<EngineResponse>.Continuation?
    
    init(loggingEnabled: Bool = false) {
        self.loggingEnabled = loggingEnabled
        
        Task{ await setAsyncStream() }
    }
    
    func setLoggingEnabled(loggingEnabled: Bool) async {
        self.loggingEnabled = loggingEnabled
    }
    
    func setInitialSetupComplete(initialSetupComplete: Bool) async {
        self.initialSetupComplete = initialSetupComplete
    }
    
    func setIsRunning(isRunning: Bool) async {
        self.isRunning = isRunning
    }
    
    func setAsyncStream() async {
        guard self.asyncStream == nil else { return }
        
        self.asyncStream = AsyncStream { (continuation: AsyncStream<EngineResponse>.Continuation) -> Void in
            Task{ await setStreamContinuation(continuation) }
        }
    }
    
    private func clearAsyncStream() async {
        self.asyncStream = nil
    }
    
    private func setStreamContinuation(_ continuation: AsyncStream<EngineResponse>.Continuation?) async {
        self.streamContinuation = continuation
        self.streamContinuation?.onTermination = { [weak self] _ in
            Task{ await self?.clearAsyncStream() }
        }
    }
}
