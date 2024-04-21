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
};

#endif /* engine_h */
