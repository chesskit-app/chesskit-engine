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
