//
//  EngineMessenger.m
//  ChessKitEngine
//

#import "EngineMessenger.h"
#import "../Engines/AvailableEngines.h"
#include <signal.h>

@implementation EngineMessenger : NSObject

dispatch_queue_t _queue;
Engine *_engine;
NSPipe *_readPipe;
NSPipe *_writePipe;
NSFileHandle *_pipeReadHandle;
NSFileHandle *_pipeWriteHandle;
NSLock *_lock;

/// Initializes a new `EngineMessenger` with default engine `Stockfish`.
- (id)init {
  return [self initWithEngineType:EngineTypeStockfish];
}

- (id)initWithEngineType: (EngineType_objc) type {
  self = [super init];

  if (self) {
    signal(SIGPIPE, SIG_IGN);
   _lock = [[NSLock alloc] init];
    switch (type) {
      case EngineTypeStockfish:
        _engine = new StockfishEngine();
        break;
      case EngineTypeLc0:
        _engine = new Lc0Engine();
        break;
    }
  }

  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _engine->deinitialize();
}

- (void)start {
  [_lock lock];
  // set up read pipe
  _readPipe = [NSPipe pipe];
  _pipeReadHandle = [_readPipe fileHandleForReading];

  dup2([[_readPipe fileHandleForWriting] fileDescriptor], fileno(stdout));

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(readStdout:)
   name:NSFileHandleReadCompletionNotification
   object:_pipeReadHandle
  ];

  dispatch_async(dispatch_get_main_queue(), ^{
    // This has to run on a thread that has an active run loop
    // otherwise we don't get notified when a read occurs.
    // Since we are using async, the only active run loop we can
    // guarentee to have an active run loop is the main thread.
    [_pipeReadHandle readInBackgroundAndNotify];
  });

  // set up write pipe
  _writePipe = [NSPipe pipe];
  _pipeWriteHandle = [_writePipe fileHandleForWriting];
  dup2([[_writePipe fileHandleForReading] fileDescriptor], fileno(stdin));

  // create command dispatch queue and start engine
  _queue = dispatch_queue_create("ck-engine-response-queue", DISPATCH_QUEUE_CONCURRENT);

  dispatch_async(_queue, ^{
    _engine->initialize();
  });
  [_lock unlock];
}

- (void)stop {
  [_lock lock];

  // Remove read notifications before closing any handles
  if (_pipeReadHandle) {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:_pipeReadHandle];
  }

  // Close write side first to signal EOF to the reader and avoid further writes
  if (_pipeWriteHandle) {
      @try {
          [_pipeWriteHandle closeAndReturnError:nil];
      } @catch (NSException *exception) {
          NSLog([exception description]);
      }
  }

  _pipeWriteHandle = nil;
  _writePipe = nil;

  // Close read side
  if (_pipeReadHandle) {
    @try {
      [_pipeReadHandle closeAndReturnError:nil];
    } @catch (NSException *exception) {
      NSLog([exception description]);
    }
  }

  _pipeReadHandle = nil;
  _readPipe = nil;

  [_lock unlock];
}

- (void)sendCommand: (NSString*) command {
  dispatch_sync(_queue, ^{
    if (!_pipeWriteHandle) { return; }
    NSString *line = [command stringByAppendingString:@"\n"];
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!data) { return; }
    
    ssize_t fd = [_pipeWriteHandle fileDescriptor];
    
    if (fd < 0) { return; }

    ssize_t result = write(fd, [data bytes], [data length]);
    (void)result;
  });
}

# pragma mark Private

- (void)readStdout: (NSNotification*) notification {
  [_pipeReadHandle readInBackgroundAndNotify];

  NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
  NSArray<NSString *> *output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];

  [output enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [self responseHandler](obj);
  }];
}

@end
