//
//  stockfish+engine.h
//  ChessKitEngine
//

#ifndef stockfish_engine_h
#define stockfish_engine_h

#import "engine.h"
#import <string>

/// Stockfish implementation of `Engine`.
class StockfishEngine: public Engine {
public:
    void initialize();
    void deinitialize();
    void send_command(const std::string &cmd);
};

#endif /* stockfish_engine_h */
