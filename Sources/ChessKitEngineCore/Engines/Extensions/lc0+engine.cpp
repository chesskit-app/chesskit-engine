//
//  lc0+engine.cpp
//  ChessKitEngine
//

#include "lc0+engine.h"

#include "../lc0/src/_main.h"

void Lc0Engine::initialize() {
  const char* argv[] = { "uci" };
  _main(sizeof(argv) / sizeof(argv[0]), argv);
}

void Lc0Engine::deinitialize() {

}
