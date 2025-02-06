//
//  Engine.swift
//  ChessKitEngine
//

import ChessKitEngineCore

public final class Engine: Sendable {
    
    //MARK: - Public properties
    
    /// The type of the engine.
    public let type: EngineType

    /// Whether the engine is currently running.
    ///
    /// - To start the engine, call ``start(coreCount:multipv:)``.
    /// - To stop the engine, call ``stop()``.
    ///
    /// Engine must be running for ``send(command:)`` to work.
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
    
    /// an AsyncStream that is called when engine responses are received.
    ///
    /// The underlying value ``EngineResponse`` contains the engine
    /// response corresponding to the UCI protocol.
    public var responseStream : AsyncStream<EngineResponse>? {
        get async { await engineConfigurationActor.asyncStream }
    }
    
    //MARK: - Private properties
    
    ///Actor used to hold mutating data in a thread safe environment.
    private let engineConfigurationActor: EngineConfiguration
    
    /// Messenger used to communicate with engine.
    private let messenger: EngineMessenger
    
    private let queue = DispatchQueue(
        label: "ck-engine-queue",
        qos: .userInteractive
    )
        
    //MARK: - Life cycle functions
    
    /// Initializes an engine with the provided ``EngineType`` and optional logging enabled flag.
    ///
    /// - parameter type: The type of engine to use.
    /// - parameter loggingEnabled: If set to `true`, engine commands and responses
    ///   will be logged to the console. The default value is `false`.
    public init(type: EngineType, loggingEnabled: Bool = false) {
        self.type = type
        self.messenger = EngineMessenger(engineType: type.objc)
        self.engineConfigurationActor = EngineConfiguration(loggingEnabled: loggingEnabled)
    }


    // This no longer work in an async environment as stop function outlives the deinit function.
    // Support for async deinit should be added in a future version of Swift (6.1)
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
    //    deinit {
    //        stop()
    //    }

    //MARK: - Public functions
    
    /// Starts the engine.
    ///
    /// You must call this function and wait for ``EngineResponse/readyok``
    /// before you can ask the engine to perform any work.
    ///
    /// - parameter coreCount: The number of processor cores to use for engine
    /// calculation. The default value is `nil` which uses the number of
    /// cores available on the device.
    /// - parameter multipv: The number of lines the engine should return,
    /// sent via the `"MultiPV"` UCI option.
    ///
    public func start(
        coreCount: Int? = nil,
        multipv: Int = 1
    ) async {
        //Setup async stream response if not already set.
        await engineConfigurationActor.setAsyncStream()
        
        setMessengerResponseHandler(coreCount: coreCount, multipv: multipv)
        messenger.start()

        // start engine setup loop
        await send(command: .uci)
    }

    /// Stops the engine.
    ///
    /// Call this to stop all engine calculation and clean up.
    /// After calling ``stop()``, ``start(coreCount:multipv:)`` must be called before
    /// sending any more commands with ``send(command:)``.
    ///
    /// - note: as temporary fix this function must be called before deiniting the engine.
    public func stop() async {
        guard await isRunning == true else { return }
            
        await send(command: .stop)
        await send(command: .quit)
        messenger.stop()
            
            
        await engineConfigurationActor.clearAsyncStream()
        await engineConfigurationActor.setIsRunning(isRunning: false)
        await engineConfigurationActor.setInitialSetupComplete(initialSetupComplete: false)
    }

    /// Sends a command to the engine.
    ///
    /// - parameter command: The command to send.
    ///
    /// Commands must be of type ``EngineCommand`` to ensure
    /// validity.
    ///
    /// Any responses will be returned via ``responseStream``.
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
    
    /// Enable printing logs to console.
    ///
    /// - parameter loggingEnabled: If set to `true`, engine commands and responses
    ///   will be logged to the console. The default value is `false`.
    ///
    public func setLoggingEnabled(_ loggingEnabled: Bool) {
        Task {
            await engineConfigurationActor
                .setLoggingEnabled(loggingEnabled: loggingEnabled)
        }
    }

    // MARK: - Private functions

    /// Logs `message` if `loggingEnabled` is `true`.
    private func log(_ message: String) async {
        if await loggingEnabled {
            Logging.print(message)
        }
    }
    
    /// convinience function to set up `messenger.responseHandler`
    private func setMessengerResponseHandler(
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

//MARK: EngineConfiguration actor

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
    
    func clearAsyncStream() async {
        self.asyncStream = nil
        self.streamContinuation = nil
    }
    
    private func setStreamContinuation(_ continuation: AsyncStream<EngineResponse>.Continuation?) async {
        self.streamContinuation = continuation
    }
}
