//
//  Logging.h
//  ChessKitEngine
//

#ifndef Logging_h
#define Logging_h

#import <Foundation/Foundation.h>

#if __has_feature(objc_arc)
  #define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
  #define DLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

@interface Logging : NSObject

+ (void)print: (NSString* _Nullable) message;

@end

#endif /* Logging_h */
