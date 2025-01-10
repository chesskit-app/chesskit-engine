# ♟️🤖 ChessKitEngine

<!--[![checks](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml/badge.svg)](https://github.com/chesskit-app/chesskit-engine/actions/workflows/checks.yaml) [![codecov](https://codecov.io/github/chesskit-app/chesskit-engine/branch/master/graph/badge.svg?token=TDS6QOD25U)](https://codecov.io/gh/chesskit-app/chesskit-engine) -->

A Swift package for the following chess engines:

<table>
    <tr>
        <td valign="center">
            <a href="https://stockfishchess.org"><img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="50" /></a>
        </td>
        <td valign="center">
            <a href="https://lczero.org"><img src="https://lczero.org/images/logo.svg" width="50" /></a>
        </td>
        <td valign="center">
            <a href="https://arasanchess.org"><img src="https://www.arasanchess.org/arasan2.gif" width="50" /></a>
        </td>
    </tr>
</table>

`chesskit-engine` implements the [Universal Chess Interface protocol](https://backscattering.de/chess/uci/2006-04.txt) for communication between [chess engines](https://en.wikipedia.org/wiki/Chess_engine) and user interfaces built with Swift.

For a related Swift package that manages chess logic, see [chesskit-swift](https://github.com/chesskit-app/chesskit-swift).

## Usage

1. Add `chesskit-engine` as a dependency
    * in an [app built in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app),
    * or [as a dependency to another Swift Package](https://www.swift.org/documentation/package-manager/#importing-dependencies).

2. Next, import `ChessKitEngine` to use it in Swift code:
``` swift
import ChessKitEngine

// ...

```

⚠️ Be sure to check the [Neural Networks](https://github.com/Amir-Zucker/async-chesskit-engine/tree/feature/add-arasan-chess?tab=readme-ov-file#neural-networks) section below for important setup details.

## Features

* Initialize an engine and set response stream
``` swift
// create Stockfish engine
let engine = Engine(type: .stockfish)

// set response stream, called when engine issues responses
for await response in await engine.responseStream! {
    print(response)
}

// start listening for engine responses
engine.start()
```

* Send [UCI protocol](https://backscattering.de/chess/uci/2006-04.txt) commands
``` swift
// check that engine is running before sending commands
guard await engine.isRunning else { return }

// stop any current engine processing
await engine.send(command: .stop)

// set engine position to standard starting chess position
await engine.send(command: .position(.startpos))

// start engine analysis with maximum depth of 15
await engine.send(command: .go(depth: 15))
```

* Update engine position after a move is made
``` swift
// FEN after 1. e4
let newPosition = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"

await engine.send(command: .stop)
await engine.send(command: .position(.fen(newPosition)))
await engine.send(command: .go(depth: 15))
```

* Receive engine's analysis of current position
``` swift
// responseStream is called whenever the engine publishes a response
for await response in await engine.responseStream! {
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
await engine.stop()
```

* Enable engine response logging
``` swift
// log engine commands and responses to the console
engine.setLoggingEnabled(true)

// Logging is off by default since engines can be very
// verbose while analyzing positions and returning evaluations.
```

## Neural Networks
Both `Stockfish 17`, `LeelaChessZero 0.31.1` and `Arasan 25.0` require neural network files to be provided to the engine for computation.
In order to keep the package size small and allow for the greatest level of flexibility, these neural network files are **not** bundled with the package. Therefore they must be added to the app (either in the bundle or manually by a user) and then provided to the engine at runtime.

For Stockfish and Lc0, they can be provided to the engine using the `.setoption(id:value:)` UCI commands included in `chesskit-engine`.

For example:
``` swift
// Stockfish
await engine.send(command: .setoption(id: "EvalFile", value: fileURL))
await engine.send(command: .setoption(id: "EvalFileSmall", value: smallFileURL))

// Lc0
await engine.send(command: .setoption(id: "WeightsFile", value: fileURL))
```
For Arasan the file needs to be set in the arasan.rc file to the following:  
1. Rename the nnue file to `arasan.nnue`
2. Open the arsan.rc file, uncomment the line `search.nnueFile=`
3. set its value to `arasan.nnue`

The following details the recommended files for each engine and where to obtain them.

#### Stockfish
* `"EvalFile"`: `nn-1111cefa1111.nnue` ([download here](https://tests.stockfishchess.org/nns?network_name=1111cefa1111&user=))
* `"EvalFileSmall"`: `nn-37f18f62d772.nnue` ([download here](https://tests.stockfishchess.org/nns?network_name=37f18f62d772&user=))
* Other files from https://tests.stockfishchess.org can be used if desired.

#### LeelaChessZero
⚠️ There are currently some performance issues with lc0 in `chesskit-engine` ([PR's are welcome!](https://github.com/chesskit-app/chesskit-engine/compare)).
* `"WeightsFile"`: `192x15_network` ([download here](https://github.com/chesskit-app/chesskit-engine/tree/0f11891b3c053e12d04c2e9c9d294c4404b006c3/Tests/ChessKitEngineTests/EngineTests/Resources))
* Other files can be obtained [here](https://lczero.org/play/bestnets/) or [here](https://training.lczero.org/networks/).

#### Arasan
arasan.rc, arasan.nnue (arasanv3-20241109.nnue) and book.bin can be found in the Tests/Resources folder.  

* Unmodified versions of `arasan.rc` can be found at: /Sources/ChessKitEngineCore/Engines/Arasan/src/arasan.rc    
* Both `book.bin` and `arasan.nnue` files are bundled with official ([arasan distributions](https://arasanchess.org/downld.shtml))


## Supported Engines

The following engines are currently supported:
| | Engine  | Version | License | Options Reference |
| :---: | --- | :---: | :---: | :---: |
| <img src="https://stockfishchess.org/images/logo/icon_512x512.png" width="25" /> | [Stockfish](https://stockfishchess.org) | [17](https://github.com/official-stockfish/Stockfish/tree/sf_17) | [GPL v3](https://github.com/official-stockfish/Stockfish/blob/sf_17/Copying.txt) | [🔗](https://github.com/official-stockfish/Stockfish/wiki/UCI-&-Commands#setoption)
| <img src="https://lczero.org/images/logo.svg" width="25" /> | [lc0](https://lczero.org) | [0.31.1](https://github.com/LeelaChessZero/lc0/tree/v0.31.1) | [GPL v3](https://github.com/LeelaChessZero/lc0/blob/v0.31.1/COPYING) | [🔗](https://github.com/LeelaChessZero/lc0/wiki/Lc0-options)
| <img src="https://www.arasanchess.org/arasan2.gif" width="25" /> | [Arasan](https://www.arasanchess.org) | [25.0](https://github.com/Amir-Zucker/arasan-chess-monochrome) | [MIT License](https://github.com/Amir-Zucker/arasan-chess-monochrome/blob/master/LICENSE) | [🔗](https://github.com/Amir-Zucker/arasan-chess-monochrome?tab=readme-ov-file#uci-options)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/Amir-Zucker/async-chesskit-engine/blob/master/LICENSE).
