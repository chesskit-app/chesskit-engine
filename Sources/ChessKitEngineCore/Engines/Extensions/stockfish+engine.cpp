//
//  stockfish+engine.m
//  ChessKitEngine
//

#import "stockfish+engine.h"
#import "../Stockfish/src/_main.h"
#import "../Stockfish/src/thread.h"

using namespace Stockfish;

void StockfishEngine::initialize() {
    _main(1, (char* []){""});
}

void StockfishEngine::deinitialize() {
    ThreadPool().end();
}

void StockfishEngine::send_command(const std::string &cmd) {
//    UCI::execute_command(cmd);
}
