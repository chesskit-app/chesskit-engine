//
//  EngineMessenger.m
//  ChessKitEngine
//

#import "EngineMessenger.h"
#import "../Engines/Extensions/stockfish+engine.h"

@implementation EngineMessenger : NSObject

Engine *_engine;
NSPipe *_pipe;
NSFileHandle *_pipeReadHandle;

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
        }
        
        _engine->initialize();
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _engine->deinitialize();
}

- (void)start {
    _pipe = [NSPipe pipe];
    _pipeReadHandle = [_pipe fileHandleForReading];
    
    dup2([[_pipe fileHandleForWriting] fileDescriptor], fileno(stdout));
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(readStdout:)
     name:NSFileHandleReadCompletionNotification
     object:_pipeReadHandle
    ];
    
    [_pipeReadHandle readInBackgroundAndNotify];
}

- (void)stop {
    [_pipeReadHandle closeFile];
    
    _pipe = NULL;
    _pipeReadHandle = NULL;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) sendCommand: (NSString*) command {
    _engine->send_command(std::string([command UTF8String]));
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
