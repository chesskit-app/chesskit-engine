//
//  Logging.m
//  ChessKitEngine
//

#import "Logging.h"

@implementation Logging

// define DLog as NSLog replacement without timestamp
// see https://stackoverflow.com/a/17311835/7264964

#if __has_feature(objc_arc)
#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define DLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

+ (void)print:(NSString *)message {
  DLog(@"%@", message)
}

@end
