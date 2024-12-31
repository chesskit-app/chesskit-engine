//
//  arasan+engine.cpp
//
//  Created by Chris Ameter on 10/10/23.
//

#import "arasan+engine.h"

#include "../Arasan/src/types.h"
#include "../Arasan/src/globals.h"
#include "../Arasan/src/options.h"
#include "../Arasan/src/protocol.h"

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
    if (!globals::initGlobals()) {
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
