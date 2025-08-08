//
//  EngineMessenger.m
//  ChessKitEngine
//

#import "EngineMessenger.h"
#import "../Engines/AvailableEngines.h"

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
    _lock = [[NSLock alloc] init];
    _outputBuffer = [NSMutableString string];
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
  [_pipeReadHandle closeFile];
  [_pipeWriteHandle closeFile];

  _readPipe = NULL;
  _pipeReadHandle = NULL;

  _writePipe = NULL;
  _pipeWriteHandle = NULL;

  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_lock unlock];
}

- (void)sendCommand: (NSString*) command {
  dispatch_sync(_queue, ^{
    const char *cmd = [[command stringByAppendingString:@"\n"] UTF8String];
    write([_pipeWriteHandle fileDescriptor], cmd, strlen(cmd));
  });
}

# pragma mark Private

- (void)readStdout:(NSNotification*)notification {
    [_pipeReadHandle readInBackgroundAndNotify];
    
    NSData *data = notification.userInfo[NSFileHandleNotificationDataItem];
    if (!data || data.length == 0) return;
    
    NSString *chunk = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!chunk) return;
    
    [self.outputBuffer appendString:chunk];
    
    NSArray<NSString *> *lines = [self.outputBuffer componentsSeparatedByString:@"\n"];
    
    // Keep the last line in the buffer if it's incomplete
    NSUInteger lastIndex = lines.count - 1;
    for (NSUInteger i = 0; i < lastIndex; i++) {
        NSString *line = lines[i];
        if (line.length > 0) {
            [self responseHandler](line);
        }
    }
    
    // Reset the buffer with the last (possibly partial) line
    [self.outputBuffer setString:lines[lastIndex]];
}

@end
