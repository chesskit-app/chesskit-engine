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

void ArasanEngine::initialize() {
    signal(SIGINT,SIG_IGN);

    //print arasan data to console.
    std::cout << "Arasan " Arasan_Version << ' ' << Arasan_Copyright << std::endl;
    // Must use unbuffered console
    setbuf(stdin,NULL);
    setbuf(stdout, NULL);
    std::cout.rdbuf()->pubsetbuf(NULL, 0);
    std::cin.rdbuf()->pubsetbuf(NULL, 0);
    
    copyBundleFiles();
    
    Bitboard::init();
    Board::init();
    globals::initOptions();
    Attacks::init();
    Scoring::init();
    Search::init();
    if (!globals::initGlobals()) {
        std::cerr << "failed to init arasan chess engine" << std::endl;
        deinitialize();
        return;
    }

    struct rlimit rl;
    const rlim_t STACK_MAX = static_cast<rlim_t>(globals::LINUX_STACK_SIZE);
    auto result = getrlimit(RLIMIT_STACK, &rl);
    if (result == 0)
    {
        if (rl.rlim_cur < STACK_MAX && rl.rlim_max <= STACK_MAX)
        {
            rl.rlim_cur = STACK_MAX;
            result = setrlimit(RLIMIT_STACK, &rl);
            if (result)
            {
                std::cerr << "failed to increase stack size" << std::endl;
                deinitialize();
                return;
            }
        }
    }

    bool ics = true, trace = false, cpusSet = false, memorySet = false;
    
    Board board;
    protocol = new Protocol(board, trace, ics, cpusSet, memorySet);
    // Begins protocol (UCI) run loop, listening on standard input
    protocol->poll(globals::polling_terminated);
    
    delete protocol;
}

void ArasanEngine::deinitialize() {
    globals::polling_terminated = true;
    globals::cleanupGlobals();
}

void ArasanEngine::copyBundleFiles() {
    copyBundleFile(CFSTR("arasan"), CFSTR("nnue"));
    copyBundleFile(CFSTR("arasan"), CFSTR("rc"));
    copyBundleFile(CFSTR("book"), CFSTR("bin"));
}

void ArasanEngine::copyBundleFile(CFStringRef fileName, CFStringRef fileExtenstion) {
    std::string cFileName = CFStringGetCStringPtr(fileName, kCFStringEncodingUTF8);
    std::string cFileExtension = CFStringGetCStringPtr(fileExtenstion, kCFStringEncodingUTF8);
    std::filesystem::path targetFolder = getenv("HOME");
    std::filesystem::path sourceFile;
    
    //Check if we are running on xctests env therefore mainBundle is com.apple.dt.xctest.tool which does not contain our resource bundle.
    if (getenv("XCTestBundlePath") != nullptr) {
        std::string env = getenv("XCTestBundlePath");
        
        sourceFile = env + "/ChessKitEngine_ChessKitEngineTests.bundle/" + cFileName + "." + cFileExtension;
    } else {
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef fileUrlRef = CFBundleCopyResourceURL(mainBundle, fileName, fileExtenstion, NULL);
        
        if (fileUrlRef != nullptr) {
            CFStringRef fileStringRef = CFURLGetString(fileUrlRef);
            std::string temp = CFStringGetCStringPtr(fileStringRef, kCFStringEncodingUTF8);
            std::string replace = "file://";
            
            sourceFile =  temp.replace(0, replace.size(), "");
        }
    }
    
    if (!sourceFile.empty()) {
        auto target = targetFolder / sourceFile.filename();
        
        try
        {
            std::filesystem::copy_file(sourceFile, target, std::filesystem::copy_options::overwrite_existing);
        }
        catch (std::exception& e)
        {
            std::cout << e.what();
        }
    }
}


