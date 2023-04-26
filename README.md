# ♟️🤖 ChessKitEngine

[![ChessKitEngine Tests](https://github.com/chesskit-app/chesskit-engine/actions/workflows/test-chesskit-engine.yml/badge.svg)](https://github.com/chesskit-app/chesskit-engine/actions/workflows/test-chesskit-engine.yml) [![codecov](https://codecov.io/github/chesskit-app/chesskit-engine/branch/master/graph/badge.svg?token=TDS6QOD25U)](https://codecov.io/gh/chesskit-app/chesskit-engine)

A Swift package for chess engines.

`ChessKitEngine` implements the [Universal Chess Interface protocol](https://backscattering.de/chess/uci/2006-04.txt) for communication between [chess engines](https://en.wikipedia.org/wiki/Chess_engine) and user interfaces built with Swift.

## Usage

* Add a package dependency to your Xcode project or Swift Package:
``` swift
.package(url: "https://github.com/chesskit-app/chesskit-engine", from: "0.1.0")
```

* Next you can import `ChessKitEngine` to use it in your Swift code:
``` swift
import ChessKitEngine

// ...

```

## Features

* Initialize an engine and set response handler
``` swift
// create Stockfish engine
let engine = Engine(type: .stockfish)

// set response handler
engine.receiveResponse = { response in
    print(response)
}

// start listening for engine responses
engine.start()
```

* Send [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt) commands
``` swift
// check that engine is running before sending commands
guard engine.isRunning else { return }

// stop any current engine processing
engine.send(command: .stop)

// set engine position to standard starting chess position
engine.send(command: .position(.startpos))

// start engine analysis with maximum depth of 15
engine.send(command: .go(depth: 15))
```

* Update engine position after a move is made
``` swift
// FEN after 1. e4
let newPosition = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"

engine.send(command: .stop)
engine.send(command: .position(.fen(newPosition))
engine.send(command: .go(depth: 15))
```

* Receive engine's analysis of current position
``` swift
// receiveResponse is called whenever the engine publishes a response
engine.receiveResponse = { response in
    switch response {
    case let .info(info):
        print(info.score)   // engine evaluation score in centipawns
        print(info.pv)      // array of move strings representing best line
    default:
        break
}
```

* Terminate engine communication
``` swift
// stop listening for engine responses
engine.stop()
```

* Enable engine response logging
``` swift
// log engine commands and responses to the console
engine.loggingEnabled = true

// Logging is off by default since engines can be very
// verbose while analyzing positions and returning evaluations.
```

## Supported Engines

The following engines are currently supported:

* [Stockfish 15.1](https://github.com/official-stockfish/Stockfish/tree/sf_15.1) ([License](https://github.com/official-stockfish/Stockfish/blob/sf_15.1/Copying.txt)) ([Options Reference](https://github.com/official-stockfish/Stockfish/tree/sf_15.1#the-uci-protocol-and-available-options))
* [LeelaChessZero (lc0) 0.29](https://github.com/LeelaChessZero/lc0/tree/v0.29.0) ([License](https://github.com/LeelaChessZero/lc0/blob/v0.29.0/COPYING)) ([Options Reference](https://github.com/LeelaChessZero/lc0/wiki/Lc0-options))

## Author

[@pdil](https://github.com/pdil)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/chesskit-app/chesskit-engine/blob/master/LICENSE).
