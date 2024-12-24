//
//  EngineMessenger.h
//  ChessKit
//

#ifndef EngineMessenger_h
#define EngineMessenger_h

#import <Foundation/Foundation.h>
#import "../Engines/EngineType_objc.h"

@class EngineMessenger;

# pragma mark - EngineMessenger

/// Messenger to communicate with the specified chess engine.
NS_SWIFT_SENDABLE
@interface EngineMessenger : NSObject

/// Called whenever a response is received from the engine.
///
/// - parameter response: The response from the engine. The string should
/// be expected to be a documented response in the [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt).
///
/// Engines work asynchronously so use this block to subscribe to
/// any commands received from the engine.
@property (nullable) void (^ responseHandler)(NSString * _Nonnull response);

/// Initializes an engine with the desired type.
///
/// - parameter type: The engine type to use.
///
/// For possible types, see `EngineType`. The default type
/// is `EngineTypeStockfish`.
///
- (id _Nonnull)initWithEngineType: (EngineType_objc) type;

/// Opens communicatation channel with the registered engine.
///
/// This must be called before `sendCommand:`.
- (void)start;

/// Closes communication channel with the registered engine.
///
/// This should be called after engine communication is no
/// longer required.
- (void)stop;

/// Sends a command to the engine.
///
/// - parameter command: The command to send to the engine.
/// The string should be a documented command in the [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt).
///
- (void) sendCommand: (NSString* _Nonnull) command;

@end

#endif /* EngineMessenger_h */
