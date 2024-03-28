
#### Improvements
* Add background engine processing for better performance.
* Remove neural network resource files for greatly reduced package size.
  * These can be added manually by bundling the desired files and setting the appropriate engine to use them (see `Resources` directory).
  * For `Stockfish 15.1` (`nn-1337b1adec5b.nnue`):
    ``` swift
    engine.send(command: .setoption(id: "EvalFile", value: evalFileURL))
    engine.send(command: .setoption(id: "Use NNUE", value: "true"))
    ```
  * For `LeelaChessZero 0.29` (`192x15_network`):
    ``` swift
    engine.send(command: .setoption(id: "WeightsFile", value: weightsFileURL))
    ```

# ChessKitEngine 0.2.2
Released Thursday, May 18, 2023.

* Replaced submodule URLs with HTTPS instead of SSH

# ChessKitEngine 0.2.1
Released Friday, April 28, 2023.

#### Improvements
* Removed unsafe flags from `Package.swift`

# ChessKitEngine 0.2.0
Released Wednesday, April 26, 2023.

#### New Features
* Add [`LeelaChessZero (lc0)` engine](https://lczero.org)
  * Currently comes bundled with a neural network weights file `192x15_network`
  
#### Improvements
* `Engine` initializer no longer has a default `engineType` (previously `.stockfish`)
  * Type must be specified using `Engine(type: <engine type>)`
* Add Stockfish `EvalFile` as Swift package resource

# ChessKitEngine 0.1.3
Released Saturday, April 15, 2023.

#### Improvements
* Add default `nil` value for `value` parameter in `EngineCommand.setoption(id:value:)`

#### Bug Fixes
* Fix `loggingEnabled` default value to match documentation
* Fix `EngineCommand.PositionString(rawValue:)` when passing a FEN string

#### Technical Improvements
* Simplify internal Obj-C and C++ targets
* Increase test coverage

# ChessKitEngine 0.1.2
Released Friday, April 14, 2023.

* Hide internal Obj-C and C++ targets
    * Created separate Swift and Obj-C `EngineType` enums
    * Package user should only need to import `ChessKitEngine` now

# ChessKitEngine 0.1.1
Released Friday, April 14, 2023.

* Fix build issue related to missing `ChessKitEngine_Cxx` target
        
# ChessKitEngine 0.1.0
Released Friday, April 14, 2023.

* Initial release
