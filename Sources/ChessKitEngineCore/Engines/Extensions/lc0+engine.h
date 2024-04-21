//
//  lc0+engine.m
//  ChessKitEngine
//

#ifndef lc0_engine_h
#define lc0_engine_h

#include "engine.h"
#include <string>

/// LeelaChessZero (Lc0) implementation of `Engine`.
class Lc0Engine: public Engine {
public:
    void initialize();
    void deinitialize();
    void send_command(const std::string &cmd);
};

#endif /* lc0_engine_h */
