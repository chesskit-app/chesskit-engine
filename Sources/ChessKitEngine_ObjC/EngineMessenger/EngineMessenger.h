//
//  EngineMessenger.h
//  ChessKit
//

#ifndef EngineMessenger_h
#define EngineMessenger_h

#import <Foundation/Foundation.h>
#import "EngineType_ObjC.h"

@protocol EngineMessengerDelegate;
@class EngineMessenger;

# pragma mark - EngineMessenger

/// Messenger to communicate with the specified chess engine.
@interface EngineMessenger : NSObject

/// The delegate used to receive responses from the registered engine.
@property (nonatomic, weak, nullable) id<EngineMessengerDelegate> delegate;

/// Initializes an engine with the desired type.
///
/// - parameter type: The engine type to use.
///
/// For possible types, see `EngineType`. The default type
/// is `EngineTypeStockfish`.
///
- (_Nonnull id)initWithEngineType: (EngineType_ObjC) type;

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

# pragma mark - EngineMessengerDelegate

/// Delegate which provides a method for receiving chess engine responses.
@protocol EngineMessengerDelegate

/// Called whenever a response is received from the engine.
///
/// - parameter messenger: The messenger that is facilitating
/// engine communication.
/// - parameter respones: The response from the engine. The string should
/// be expected to be a documented response in the [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt).
///
/// Engines work asynchronously so use this method to subscribe to
/// any commands received from the engine.
///
- (void)messenger:(EngineMessenger * _Nonnull)messenger didReceiveResponse:(NSString * _Nonnull)response;

@end

#endif /* EngineMessenger_h */
