//
//  arasan+engine.cpp
//
//  Created by Chris Ameter on 10/10/23.
//

#import "arasan+engine.h"

#include "../arasan-chess/src/types.h"
#include "../arasan-chess/src/globals.h"
#include "../arasan-chess/src/options.h"
#include "../arasan-chess/src/protocol.h"

#include <iostream>
#include <fstream>

Protocol *protocol;
Board board;

void ArasanEngine::initialize() {
    signal(SIGINT,SIG_IGN);

    // Show a message on the console
    std::cout << "Arasan " Arasan_Version << ' ' << Arasan_Copyright << std::endl;
    // Must use unbuffered console
    setbuf(stdin,NULL);
    setbuf(stdout, NULL);
    std::cout.rdbuf()->pubsetbuf(NULL, 0);
    std::cin.rdbuf()->pubsetbuf(NULL, 0);

    Bitboard::init();
    Board::init();
    globals::initOptions();
    Attacks::init();
    Scoring::init();
    Search::init();
    if (!globals::initGlobals(true)) {
        globals::cleanupGlobals();
        exit(-1);
    }

    struct rlimit rl;
    const rlim_t STACK_MAX = static_cast<rlim_t>(globals::LINUX_STACK_SIZE);
    auto result = getrlimit(RLIMIT_STACK, &rl);
    if (result == 0)
    {
        if (rl.rlim_cur < STACK_MAX)
        {
            rl.rlim_cur = STACK_MAX;
            result = setrlimit(RLIMIT_STACK, &rl);
            if (result)
            {
                std::cerr << "failed to increase stack size" << std::endl;
                exit(-1);
            }
        }
    }

    bool ics = true, trace = false, cpusSet = false, memorySet = false;

    protocol = new Protocol(board, trace, ics, cpusSet, memorySet);
    // Begins protocol (UCI) run loop, listening on standard input
    // protocol->poll(globals::polling_terminated);
}

void ArasanEngine::deinitialize() {
    globals::cleanupGlobals();
    delete protocol;
}

void ArasanEngine::send_command(const std::string &cmd) {
    protocol->do_command(cmd, board);
}
