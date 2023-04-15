# 🤖 ChessKitEngine

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
import ChessKit
let position = Position()

if engine.isRunning {
    engine.send(command: .stop)
    engine.send(command: position)
    engine.send(command: .go(depth: 15))
}
```

* Terminate engine communication
``` swift
engine.stop()
```

## Supported Engines

The following engines are currently supported:

* [Stockfish 15.1](https://github.com/official-stockfish/Stockfish) ([License](https://github.com/official-stockfish/Stockfish/blob/acb0d204d56e16398c58822df2cc60b90ef1ae85/Copying.txt))

## Author

[@pdil](https://github.com/pdil)

## License

`ChessKitEngine` is distributed under the [MIT License](https://github.com/chesskit-app/chesskit-engine/blob/master/LICENSE).
