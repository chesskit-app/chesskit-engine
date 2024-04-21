//
//  lc0+engine.m
//  ChessKitEngine
//

#include "lc0+engine.h"

#include "../lc0/src/chess/board.h"
#include "../lc0/src/engine.h"

using namespace lczero;

EngineLoop loop;

void Lc0Engine::initialize() {
    InitializeMagicBitboards();
    loop.Initialize();
    loop.RunLoop();
}

void Lc0Engine::deinitialize() {
    
}

void Lc0Engine::send_command(const std::string &cmd) {
    auto command = loop.ParseCommand(cmd);
    
    try {
        loop.DispatchCommand(command.first, command.second);
    } catch(std::exception& e) {
        // ignore unsupported commands
    }
}
