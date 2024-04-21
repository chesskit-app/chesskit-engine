# ♟️🤖 ChessKitEngine

[![checks](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml/badge.svg)](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml) [![codecov](https://codecov.io/github/chesskit-app/chesskit-engine/branch/master/graph/badge.svg?token=TDS6QOD25U)](https://codecov.io/gh/chesskit-app/chesskit-engine)

A Swift package for the following chess engines:

<table>
    <tr>
        <td valign="center">
            <a href="https://stockfishchess.org"><img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="50" /></a>
        </td>
        <td valign="center">
            <a href="https://lczero.org"><img src="https://lczero.org/images/logo.svg" width="50" /></a>
        </td>
    </tr>
</table>

`chesskit-engine` implements the [Universal Chess Interface protocol](https://backscattering.de/chess/uci/2006-04.txt) for communication between [chess engines](https://en.wikipedia.org/wiki/Chess_engine) and user interfaces built with Swift.

For a related Swift package that manages chess logic, see [chesskit-swift](https://github.com/chesskit-app/chesskit-swift).

## Usage

1. Add `chesskit-engine` as a dependency
	* In an [app built in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app),
	* or [as a dependency to another Swift Package](https://www.swift.org/documentation/package-manager/#importing-dependencies).

2. Next, import `ChessKitEngine` to use it in Swift code:
``` swift
import ChessKitEngine

// ...

```

⚠️ Be sure to check the [Neural Networks](https://github.com/chesskit-app/chesskit-engine/tree/master?tab=readme-ov-file#neural-networks) section below for important setup details.

## Features

* Initialize an engine and set response handler
``` swift
// create Stockfish engine
let engine = Engine(type: .stockfish)

// set response handler, called when engine issues responses
engine.receiveResponse = { response in
    print(response)
}

// start listening for engine responses
engine.start {
    // engine is ready to go!
}
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

## Neural Networks
Both `Stockfish 16.1` and `LeelaChessZero 0.30` require neural network files to be provided to the engine for computation.

They can be provided to the engine using the `.setoption(id:value:)` UCI commands provided by `chesskit-engine`.

For example:
``` swift
// Stockfish
engine.send(command: .setoption(id: "EvalFile", value: fileURL))
engine.send(command: .setoption(id: "EvalFileSmall", value: smallFileURL))

// Lc0
engine.send(command: .setoption(id: "WeightsFile", value: fileURL))
```

The following details the recommended files for each engine and where to obtain them.

#### Stockfish
* `"EvalFile"`: `nn-b1a57edbea57.nnue` ([download here](https://tests.stockfishchess.org/nns?network_name=b1a57edbea57&user=))
* `"EvalFileSmall"`: `nn-baff1ede1f90.nnue` ([download here](https://tests.stockfishchess.org/nns?network_name=baff1ede1f90&user=))
* Other files from https://tests.stockfishchess.org can be used if desired.

#### LeelaChessZero
* `"WeightsFile"`: `192x15_network` ([download here](https://github.com/chesskit-app/chesskit-engine/tree/0f11891b3c053e12d04c2e9c9d294c4404b006c3/Tests/ChessKitEngineTests/EngineTests/Resources))
* Other files can be obtained [here](https://lczero.org/play/bestnets/) or [here](https://training.lczero.org/networks/).

## Supported Engines

The following engines are currently supported:
| | Engine  | Version | License | Options Reference |
| :---: | --- | :---: | :---: | :---: |
| <img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="25" /> | [Stockfish](https://stockfishchess.org) | [16.1](https://github.com/official-stockfish/Stockfish/tree/sf_16.1) | [GPL v3](https://github.com/official-stockfish/Stockfish/blob/sf_16.1/Copying.txt) | [🔗](https://github.com/official-stockfish/Stockfish/wiki/UCI-&-Commands#setoption)
| <img src="https://lczero.org/images/logo.svg" width="25" /> | [lc0](https://lczero.org) | [0.30](https://github.com/LeelaChessZero/lc0/tree/v0.30.0) | [GPL v3](https://github.com/LeelaChessZero/lc0/blob/v0.30.0/COPYING) | [🔗](https://github.com/LeelaChessZero/lc0/wiki/Lc0-options)

## Author

[@pdil](https://github.com/pdil)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/chesskit-app/chesskit-engine/blob/master/LICENSE).
