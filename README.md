# 🤖 ChessKitEngine

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
let engine = Engine(type: .stockfish)

// set response handler
engine.receiveResponse = { response in
    print(response)
}

engine.start()
```

* Send [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt) commands
``` swift
guard engine.isRunning else { return }

engine.send(command: .stop)
engine.send(command: .position(.startpos))
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
engine.stop()
```

* Enable engine response logging
``` swift
// Logging is off by default since engines can be very
// verbose while analyzing positions and returning evaluations.
engine.loggingEnabled = true
```

## Supported Engines

The following engines are currently supported:

* [Stockfish 15.1](https://github.com/official-stockfish/Stockfish) ([License](https://github.com/official-stockfish/Stockfish/blob/acb0d204d56e16398c58822df2cc60b90ef1ae85/Copying.txt))

## Author

[@pdil](https://github.com/pdil)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/chesskit-app/chesskit-engine/blob/master/LICENSE).
