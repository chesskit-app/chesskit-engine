# ♟️🤖 ChessKitEngine

[![checks](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml/badge.svg)](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml) [![codecov](https://codecov.io/github/chesskit-app/chesskit-engine/branch/master/graph/badge.svg?token=TDS6QOD25U)](https://codecov.io/gh/chesskit-app/chesskit-engine)

A Swift package for the following chess engines:

[<img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="50" />](https://stockfishchess.org) [<img src="https://lczero.org/images/logo.svg" width="50" />](https://lczero.org)

`ChessKitEngine` implements the [Universal Chess Interface protocol](https://backscattering.de/chess/uci/2006-04.txt) for communication between [chess engines](https://en.wikipedia.org/wiki/Chess_engine) and user interfaces built with Swift.

For a related Swift package that manages chess logic, see [chesskit-swift](https://github.com/chesskit-app/chesskit-swift).

## Usage

* Add a package dependency to your Xcode project or Swift Package:
``` swift
.package(url: "https://github.com/chesskit-app/chesskit-engine", from: "0.2.0")
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
engine.send(command: .position(.fen(newPosition)))
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

* Enable engine neural networks
  * Copy the relevant file in the `Resources` directory of this repo to your app's bundle, then use the engine-specific commands to provide them to the engine (where `fileURL` is a `String` of the URL of the file).
  * These must be called in the order shown.
  * For `Stockfish 15.1` (`nn-1337b1adec5b.nnue`):
    ``` swift
    engine.send(command: .setoption(id: "EvalFile", value: fileURL))
    engine.send(command: .setoption(id: "Use NNUE", value: "true"))
    ```
  * For `LeelaChessZero 0.29` (`192x15_network`):
    ``` swift
    engine.send(command: .setoption(id: "WeightsFile", value: fileURL))
    ```

## Supported Engines

The following engines are currently supported:
| | Engine  | Version | License | Options Reference |
| :---: | --- | :---: | :---: | :---: |
| <img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="25" /> | [Stockfish](https://stockfishchess.org) | [16.1](https://github.com/official-stockfish/Stockfish/tree/sf_16.1) | [GPL v3](https://github.com/official-stockfish/Stockfish/blob/sf_16.1/Copying.txt) | [🔗](https://github.com/official-stockfish/Stockfish/tree/sf_16.1#the-uci-protocol-and-available-options)
| <img src="https://lczero.org/images/logo.svg" width="25" /> | [lc0](https://lczero.org) | [0.29](https://github.com/LeelaChessZero/lc0/tree/v0.29.0) | [GPL v3](https://github.com/LeelaChessZero/lc0/blob/v0.29.0/COPYING) | [🔗](https://github.com/LeelaChessZero/lc0/wiki/Lc0-options)

## Author

[@pdil](https://github.com/pdil)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/chesskit-app/chesskit-engine/blob/master/LICENSE).
