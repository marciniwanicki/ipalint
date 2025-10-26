# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ipalint is a macOS command-line tool for linting iOS .ipa (iOS App Store Package) files. It analyzes app bundles for configuration issues, size constraints, entitlements, frameworks, and file extensions based on YAML configuration rules.

## Development Commands

### Setup
```bash
make setup  # Install mise and dependencies (swiftlint, swiftformat)
```

### Building
```bash
make build  # Build the project using Swift Package Manager
# Or directly:
xcrun swift build
```

### Testing
```bash
make test  # Run all tests
# Or directly:
xcrun swift test

# Run specific test:
xcrun swift test --filter <TestName>
```

### Linting and Formatting
```bash
make lint    # Run swiftlint and swiftformat checks
make format  # Format code with swiftformat
```

### Clean
```bash
make clean  # Clean build artifacts
```

## Code Change Workflow

**IMPORTANT**: After making any code changes to Swift files, you MUST run the following commands in order:

1. **Format the code**:
```bash
make format
```
This ensures all code is properly formatted according to the project's swiftformat configuration.

2. **Run linting checks**:
```bash
make lint
```
This verifies code quality and adherence to Swift style guidelines. Fix any linting violations before committing.

Both steps are required before committing any changes.

## Architecture

### Module Structure

The project is organized into three Swift Package Manager targets:

1. **ipalint** (executable) - Entry point
2. **IPALintCommand** - CLI layer handling ArgumentParser commands and DI
3. **IPALintCore** - Core business logic, rules, and utilities

### Dependency Injection

The project uses **SCInject** (from SwiftCommons) for dependency injection:
- `CoreAssembly` (in IPALintCore) registers core services, utilities, and rules
- `CommonAssembly` (in IPALintCommand) registers shared command-level services
- Each command has its own `Assembly` class that registers command-specific dependencies
- Dependencies are resolved through the `Registry` and accessed via `resolver.resolve(Type.self)`

### Command Architecture

The CLI uses Swift ArgumentParser with a command pattern:
- `CommandRunner` bootstraps the DI container and executes commands
- Each command (Lint, Info, Snapshot, Diff, Version) implements the `Command` protocol
- Commands delegate to **Interactors** in IPALintCore for business logic
- Results are formatted using **Renderer** classes

Available commands:
- **lint** - Lint .ipa against configuration rules (`.ipalint.yml`)
- **info** - Display .ipa metadata and entitlements
- **snapshot** - Generate a snapshot file of .ipa contents (hashes, sizes)
- **diff** - Compare two .ipa files or compare against snapshot
- **version** - Show tool version

### Lint Rule System

Rules are defined in IPALintCore/Rules/ and follow a protocol-based architecture:

1. **Rule Types** (based on input):
   - `FileLintRule` - Operates on the .ipa file itself (e.g., `IPAFileSizeLintRule`)
   - `ContentLintRule` - Operates on extracted .ipa contents (e.g., `EntitlementsLintRule`, `FrameworksLintRule`)
   - `FileSystemTreeLintRule` - Operates on the file tree (e.g., `FileExtensionsLintRule`)

2. **Rule Configuration**:
   - Rules can be configurable via `ConfigurableLintRule` protocol
   - Configuration is loaded from `.ipalint.yml` with bundle-specific and "all" bundles sections
   - Each rule defines its own `LintRuleConfiguration` struct with `warning` and `error` severity settings
   - Rules are enabled by default unless `enabled: false` is specified

3. **Adding New Rules**:
   - Create a new rule class in `Sources/IPALintCore/Rules/`
   - Implement one of the rule protocols (`FileLintRule`, `ContentLintRule`, `FileSystemTreeLintRule`)
   - Define a `LintRuleDescriptor` with identifier, name, and description
   - If configurable, implement `ConfigurableLintRule` with a configuration struct
   - Register the rule in `CoreAssembly.assembleRules()`
   - Wrap it in the appropriate `TypedLintRule` case (`.file()`, `.content()`, `.fileSystemTree()`)

### Core Utilities

Key utilities in IPALintCore/Utils/:
- **ContentExtractor** - Extracts .ipa contents using tar
- **CodesignExtractor** - Extracts entitlements using `codesign` command
- **ConfigurationLoader** - Parses `.ipalint.yml` using Yams
- **SnapshotGenerator/Parser** - Creates/reads snapshot files with file hashes
- **FileSystem** - Abstraction over filesystem operations (from swift-tools-support-core)
- **System** - Abstraction for running subprocess commands

### Configuration Format

`.ipalint.yml` structure:
```yaml
bundles:
  com.example.app:  # Specific bundle identifier
    rules:
      ipa_file_size:
        warning:
          min_size: 10 MB
          max_size: 50 MB
  all:  # Applied to all bundles unless overridden
    rules:
      entitlements:
        error:
          content:
            com.apple.security.app-sandbox: "true"
```

## Platform Requirements

- macOS 14+ (specified in Package.swift)
- Xcode with Swift 5.9+
- Uses macOS-specific tools: `tar`, `codesign`

## Testing

Tests are organized into:
- **IPALintCoreTests** - Unit tests for core utilities
- **IPALintIntegrationTests** - Integration tests for commands

### Testing Framework

The project uses the **Swift Testing framework** (not XCTest). Tests use:
- `@Suite` for test suites
- `@Test` for individual tests
- `#expect` for assertions

### Test Conventions

When writing tests, follow these conventions:

1. **System Under Test Naming**:
   - The system under test (SUT) must always be named `subject`
   - Example: `private let subject = DefaultCrypto()`

2. **Property Visibility**:
   - All test properties must be `private`
   - Example: `private let fileSystem = TSCBasic.localFileSystem`

3. **Integration Tests**:
   - Integration tests that share resources (like `CaptureOutput`) must use the `.serialized` trait
   - Example: `@Suite("Help Command Integration Tests", .serialized)`

4. **Test Descriptions**:
   - All `@Test` descriptions must start with a capitalized letter
   - Example: `@Test("SHA256 hash of empty file")` ✓
   - Example: `@Test("writes to stdout")` ✗ (should be "Writes to stdout")

5. **Test Structure**:
   - Use Given/When/Then comments to structure test logic
   - Include descriptive test names in the `@Test` attribute

Example test structure:
```swift
@Suite("Crypto Tests")
struct CryptoTests {
    private let subject = DefaultCrypto()
    private let fileSystem = TSCBasic.localFileSystem

    @Test("SHA256 hash of empty file")
    func sha256EmptyFile() throws {
        // Given
        let testFile = ...

        // When
        let hash = try subject.sha256String(at: testFile)

        // Then
        #expect(hash == "expected_hash")
    }
}
```
