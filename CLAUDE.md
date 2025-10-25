# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ipalint` is a Swift command-line tool for linting .ipa files (iOS App Store Packages). It validates iOS app packages against configurable rules and can generate snapshots, compare differences, and display app information.

## Development Commands

### Setup
```bash
make setup
```
Installs mise and required development tools (swiftlint, swiftformat).

### Build
```bash
make build
```
Compiles the project using Swift Package Manager via `xcrun swift build`.

### Test
```bash
# Run all tests
make test

# Run specific test
xcrun swift test --filter <TestName>
```

### Lint
```bash
make lint
```
Runs swiftlint (strict mode) and swiftformat in lint mode.

### Format
```bash
make format
```
Auto-formats code using swiftformat.

## Architecture

### Module Structure

The project is organized into three Swift Package Manager targets:

1. **ipalint** (executable)
   - Entry point in `Sources/ipalint/main.swift`
   - Delegates to `CommandRunner` from IPALintCommand

2. **IPALintCommand** (library)
   - CLI layer using Swift ArgumentParser
   - Commands: `lint`, `info`, `diff`, `snapshot`, `version`
   - Located in `Sources/IPALintCommand/Commands/`
   - Each command has an `Executor` and `Assembly` nested class

3. **IPALintCore** (library)
   - Business logic and core functionality
   - Organized into: Entities, Interactors, Rules, Utils

### Dependency Injection

The codebase uses a custom lightweight DI container (`Container.swift` in IPALintCore/Utils):

- **Registry**: Registers type factories
- **Resolver**: Resolves types from the container
- **Assembly**: Protocol for organizing registrations
- **Assembler**: Chains assemblies together

Key assemblies:
- `CoreAssembly` (IPALintCore): Registers rules, utils, and interactors
- `CommonAssembly` (IPALintCommand): Registers command-level services
- Each command has its own `Assembly` nested class

Registration is singleton-scoped by default via `SingletonReferenceResolver`.

### Command Pattern

Commands follow a consistent pattern:
1. Conform to `Command` protocol (extends ArgumentParser's `ParsableCommand`)
2. Define `@Option` and `@Flag` properties for CLI arguments
3. Include nested `Executor` class implementing `CommandExecutor`
4. Include nested `Assembly` class implementing `CommandAssembly`
5. The `run()` method resolves the executor via DI and calls `execute(command:)`

See `Sources/IPALintCommand/Utils/Command.swift` for the base protocol.

### Interactors

Core business logic is organized into interactors (Sources/IPALintCore/Interactors/):

- **LintInteractor**: Runs lint rules against IPA files
- **InfoInteractor**: Extracts and displays IPA metadata
- **DiffInteractor**: Compares two snapshots
- **SnapshotInteractor**: Generates/loads snapshots

Each has a protocol definition and a `Default*` implementation, plus a corresponding renderer for output formatting.

### Lint Rules

Rules are defined in `Sources/IPALintCore/Rules/` and implement one of:

- `FileLintRule`: Operates on the .ipa file directly
- `ContentLintRule`: Operates on extracted IPA contents
- `FileSystemTreeLintRule`: Operates on the file tree structure

Built-in rules:
- `IPAFileSizeLintRule`: Checks total .ipa file size
- `PayloadSizeLintRule`: Checks payload directory size
- `EntitlementsLintRule`: Validates entitlements
- `FrameworksLintRule`: Checks embedded frameworks
- `FileExtensionsLintRule`: Validates file extensions

Rules support configuration via YAML with `enabled`, `warning`, and `error` settings. Configuration uses snake_case keys that are converted to camelCase via `JSONDecoder.keyDecodingStrategy`.

Rules are registered as `[TypedLintRule]` in `CoreAssembly.swift`.

### Key Utilities

- **ContentExtractor**: Extracts .ipa contents to temporary directory
- **CodesignExtractor**: Extracts code signing information using `codesign` command
- **Archiver**: Handles tar operations (currently uses `TarArchiver`)
- **FileSystem**: Abstraction over file system operations
- **System**: Abstraction over subprocess execution
- **SnapshotGenerator/Parser**: Creates and reads snapshot JSON files
- **ConfigurationLoader**: Loads YAML configuration files

All utilities use protocol/implementation pairs for testability.

## Testing

Two test targets:

1. **IPALintCoreTests**: Unit tests for core logic
2. **IPALintIntegrationTests**: End-to-end integration tests
   - Base class: `IntegrationTestCase` in `Tests/IPALintIntegrationTests/Support/`

## Tool Configuration

- **mise** (`.mise.toml`): Manages swiftlint 0.57.0 and swiftformat 0.53.3
- **SwiftLint** (`.swiftlint.yml`): Disabled rules include `todo`, `trailing_comma`, `opening_brace`
- **Swift**: Requires macOS 14+ (see `Package.swift`)
- **Xcode**: CI uses Xcode 26.0.1
