# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2025-07-01

### Added

- Added .gitattributes, .gitignore, Readme.md, and Changelog.md
- Added Utils with useful helper functions in `src/Lib/Utils`
- Initialized new scene for game as Level1 and a layer inside it as Game.
- Added individual elm files for: `Character`, `Game`, `Ghost`and `Weapon` inside Game Layer
- Added character movement logic w.r.t user input(feature/basic_character).
- Added basic shooting ghost buster and Yellow mist render upon user input (feature/basic_character)
- Added multiple branches for each features: `feature/basic_character`, `feature/basic_ghost`, `feature/assets`
- Bug fixes in character movements
- Updated code quality for Character layer.
- Added a ghost in the game with basic characterstics
- Added SMV for GoldSpike
- Added assets for GoldSpike

## [0.1.0] - 2025-07-10

### Added

- Ghost become visible when detected by the yellow ghost buster and stay visible for a period of time after detected
- Ghost can only be attacked once per blue ghost buster shot when it is visible
- Ghost can attack character and decrease character HP
- Character and Ghost move in the bounds of the rooms

## [0.2.0] - 2025-07-17

### Refactored

- Refactored the code to using `SceneProto` feature from `Messenger`

### Added

- Background music and sound effects
- Background particle system

## [0.3.0] - 2025-07-24

### Added

- Add maps for multiple levels
- Add mushrooms
- Add skill tree system
- Add trailer

## [0.4.0] - 2025-08-01

- Update the weapon system
- Add bosses
- Add booklet and poster
- Add the dialogue system
- Add the tutorial
- Set game ending
