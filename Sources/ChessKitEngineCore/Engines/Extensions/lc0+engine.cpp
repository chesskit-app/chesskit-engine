//
//  lc0+engine.m
//  ChessKitEngine
//

#import "lc0+engine.h"

//#import "../Stockfish/src/bitboard.h"
//#import "../Stockfish/src/endgame.h"
//#import "../Stockfish/src/evaluate.h"
//#import "../Stockfish/src/position.h"
//#import "../Stockfish/src/psqt.h"
//#import "../Stockfish/src/search.h"
//#import "../Stockfish/src/thread.h"
//#import "../Stockfish/src/uci.h"
//#import "../Stockfish/src/types.h"

//using namespace Stockfish;

void Lc0Engine::initialize() {
//    Options["Use NNUE"] = true;
//
//    UCI::init(Options);
//    Tune::init();
//    PSQT::init();
//    Bitboards::init();
//    Position::init();
//    Bitbases::init();
//    Endgames::init();
//    Threads.set(size_t(Stockfish::Options["Threads"]));
//    Search::clear(); // After threads are up
//    Eval::NNUE::init();
}

void Lc0Engine::deinitialize() {
//    Threads.clear();
//    Threads.end();
}

void Lc0Engine::send_command(const std::string &cmd) {
//    UCI::execute_command(cmd);
}
