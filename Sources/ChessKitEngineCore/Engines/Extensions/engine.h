//
//  engine.h
//  ChessKitEngine
//

#ifndef engine_h
#define engine_h

#include <string>

/// Abstract `Engine` class which encapsulates
/// engine initialization, deinitialization,
/// and one-way UCI communication.
///
/// In order to receive UCI responses, monitor
/// `stdout` output.
class Engine {
public:
    /// Initializes the engine.
    ///
    /// Any required initialization and setup should
    /// be performed here.
    virtual void initialize() {};
    
    /// Deinitializes the engine.
    ///
    /// Any required deinitialization and cleanup should
    /// be performed here
    virtual void deinitialize() {};
    
    /// Sends a command to the engine.
    /// 
    /// - parameter cmd: The UCI command to send to the engine.
    /// See https://backscattering.de/chess/uci/2006-04.txt
    /// for valid commands.
    ///
    /// The output from the engine will appear in `stdout`.
    virtual void send_command(const std::string &cmd) {};
};

#endif /* engine_h */
