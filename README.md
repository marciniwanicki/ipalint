<p align="center">
  <img src="Documentation/Resources/ipalint.png" alt="ipalint logo" />
</p>

# ipalint

A macOS command-line tool for static analysis of iOS `.ipa` (iOS App Store Package) files. Analyze app bundles for configuration issues, enforce size constraints, validate entitlements, and detect prohibited file extensions using declarative YAML-based rules.

## Requirements

- **macOS 14+** (Sonoma or later)
- **Xcode** with Swift 5.9+ toolchain
- **System Dependencies**: `tar`, `codesign` (provided by macOS Command Line Tools)

## Installation

### From Source

```bash
git clone https://github.com/marciniwanicki/ipalint.git
cd ipalint
make setup   # Install dependencies (swiftlint, swiftformat)
make build   # Build with Swift Package Manager
```

The compiled binary will be located at `.build/debug/ipalint`.

### Development Tools

The project uses [mise](https://mise.jdx.dev/) for tool version management:

```bash
make setup   # Automatically installs mise and configured tools
```

## Usage

### Lint Command

Analyze an `.ipa` file against rules defined in `.ipalint.yml`:

```bash
ipalint lint path/to/Application.ipa
```

**Example Output:**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Lint result for com.example.myapp              │
│                                                 │
└─────────────────────────────────────────────────┘

✓ Package size
✓ Payload size
✗ Entitlements
  └─ Invalid entitlements property value -- property=com.apple.security.app-sandbox, expected_value=true, present_value=false
✓ Frameworks
✓ File extensions

Errors: 1, Warnings: 0
```

**Exit Codes:**
- `0` - No violations
- `1` - Warnings or errors found
- `2` - Fatal error (missing file, invalid configuration)

### Info Command

Display `.ipa` metadata and entitlements:

```bash
ipalint info path/to/Application.ipa
```

**Example Output:**

```
Bundle ID: com.example.myapp
Version: 1.2.3
Build: 456
IPA Size: 42.5 MB
Payload Size: 38.1 MB

Entitlements:
  com.apple.security.app-sandbox: true
  com.apple.security.network.client: true
  com.apple.application-identifier: TEAM123.com.example.myapp
```

### Snapshot Command

Generate a cryptographic snapshot of an `.ipa` bundle:

```bash
ipalint snapshot path/to/Application.ipa --output snapshot.json
```

### Diff Command

Compare two `.ipa` files or compare an `.ipa` against a snapshot:

```bash
# Compare two .ipa files
ipalint diff old.ipa new.ipa

# Compare .ipa against snapshot
ipalint diff --snapshot snapshot.json new.ipa
```

**Example Output:**

```
Size Changes:
  Total Size: 42.5 MB → 43.1 MB (+600 KB)
  Payload Size: 38.1 MB → 38.6 MB (+500 KB)

Modified Files:
  ✎ Payload/Application.app/Application
  ✎ Payload/Application.app/Info.plist

Added Files:
  + Payload/Application.app/Frameworks/NewFramework.framework/NewFramework

Removed Files:
  - Payload/Application.app/deprecated.png
```

### Version Command

Display the tool version:

```bash
ipalint version
```

## Configuration

Rules are configured via `.ipalint.yml` in your project directory. The configuration supports bundle-specific rules and global defaults.

### Configuration Structure

```yaml
bundles:
  com.example.specificapp:
    rules:
      # Rules specific to this bundle identifier
      ipa_file_size:
        warning:
          max_size: 100 MB

  all:
    rules:
      # Rules applied to all bundles unless overridden
      ipa_file_size:
        error:
          max_size: 150 MB

      entitlements:
        error:
          content:
            com.apple.security.app-sandbox: "true"
            com.apple.security.network.client: "true"
```

### Rule Reference

#### `ipa_file_size`

Validates the size of the `.ipa` file itself (compressed archive size).

**Configuration:**

```yaml
ipa_file_size:
  warning:
    min_size: 10 MB    # Optional: minimum size threshold
    max_size: 100 MB   # Optional: maximum size threshold
  error:
    max_size: 150 MB   # Fail if exceeds this size
```

**Size Units:** `B`, `KB`, `MB`, `GB` (base 1000), `KiB`, `MiB`, `GiB` (base 1024)

#### `payload_size`

Validates the uncompressed payload size (extracted app bundle).

**Configuration:**

```yaml
payload_size:
  warning:
    max_size: 200 MB
  error:
    max_size: 250 MB
```

#### `entitlements`

Validates entitlement key-value pairs extracted via `codesign`.

**Configuration:**

```yaml
entitlements:
  error:
    content:
      com.apple.security.app-sandbox: "true"
      com.apple.security.files.user-selected.read-write: "true"
      com.apple.application-identifier: "TEAM123.com.example.app"
      # Array values supported:
      com.apple.security.temporary-exception.files.absolute-path.read-write:
        - "/usr/local/bin"
        - "/tmp"
```

#### `frameworks`

Enforces allowlists or denylists for embedded frameworks.

**Configuration:**

```yaml
frameworks:
  error:
    # Whitelist approach (only these allowed):
    expect_only:
      - "SwiftUI"
      - "Combine"
      - "CoreData"

    # Blacklist approach (these forbidden):
    forbidden:
      - "DeprecatedFramework"
      - "InsecureLibrary"
```

#### `file_extensions`

Detects unexpected or forbidden file extensions in the bundle.

**Configuration:**

```yaml
file_extensions:
  warning:
    # Only allow these extensions:
    expect_only:
      - "nib"
      - "storyboardc"
      - "plist"
      - "png"
      - "strings"

    # Forbid these extensions:
    forbidden:
      - "txt"
      - "log"
      - "md"
      - "py"
```

### Rule Severity and Enablement

Each rule supports `warning` and `error` severity levels:

```yaml
ipa_file_size:
  warning:
    max_size: 100 MB   # Warns but doesn't fail build
  error:
    max_size: 150 MB   # Fails with exit code 1
```

Disable rules explicitly:

```yaml
frameworks:
  enabled: false   # Rule will not execute
```

### Bundle-Specific Overrides

Rules cascade from `all` to bundle-specific configurations:

```yaml
bundles:
  all:
    rules:
      ipa_file_size:
        error:
          max_size: 100 MB

  com.example.largeapp:
    rules:
      ipa_file_size:
        error:
          max_size: 200 MB   # Override for this bundle only
```

## Development

### Setup Development Environment

```bash
make setup   # Install mise and development tools
make build   # Build project
make test    # Run all tests
```

### Code Quality

```bash
make lint    # Run swiftlint and swiftformat checks
make format  # Auto-format code with swiftformat
```

### Running Tests

```bash
# All tests
make test

# Specific test
xcrun swift test --filter IPAFileSizeLintRuleTests
```

## Attributions

We would like to thank the authors and contributors of the following projects:

- [swift-argument-parser](https://github.com/apple/swift-argument-parser)
- [swift-tools-support-core](https://github.com/apple/swift-tools-support-core)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
- [mise](https://github.com/jdx/mise)

## License

ipalint is released under version 2.0 of the [Apache License](LICENSE).
