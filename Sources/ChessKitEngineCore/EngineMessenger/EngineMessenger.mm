//
//  EngineMessenger.m
//  ChessKitEngine
//

#import "EngineMessenger.h"
#import "../Engines/AvailableEngines.h"

@implementation EngineMessenger : NSObject

dispatch_queue_t _queue;
Engine *_engine;
NSPipe *_pipe1;
NSPipe *_pipe2;
NSFileHandle *_pipeReadHandle;
NSFileHandle *_pipeWriteHandle;

/// Initializes a new `EngineMessenger` with default engine `Stockfish`.
- (id)init {
    return [self initWithEngineType:EngineTypeStockfish];
}

- (id)initWithEngineType: (EngineType_objc) type {
    self = [super init];

    if (self) {
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
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _pipe1 = [NSPipe pipe];
    _pipeReadHandle = [_pipe1 fileHandleForReading];

    dup2([[_pipe1 fileHandleForWriting] fileDescriptor], fileno(stdout));

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(readStdout:)
     name:NSFileHandleReadCompletionNotification
     object:_pipeReadHandle
    ];

    [_pipeReadHandle readInBackgroundAndNotify];

    _pipe2 = [NSPipe pipe];
    _pipeWriteHandle = [_pipe2 fileHandleForWriting];
    dup2([[_pipe2 fileHandleForReading] fileDescriptor], fileno(stdin));

    dispatch_async(_queue, ^{
        _engine->initialize();
    });
}

- (void)stop {
    [_pipeReadHandle closeFile];
    [_pipeWriteHandle closeFile];

    _pipe1 = NULL;
    _pipeReadHandle = NULL;

    _pipe2 = NULL;
    _pipeWriteHandle = NULL;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendCommand: (NSString*) command {
    const char *cCommand = [[command stringByAppendingString:@"\n"] UTF8String];
    write([_pipeWriteHandle fileDescriptor], cCommand, strlen(cCommand));
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
