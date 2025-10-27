//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import Testing
import TSCBasic

@testable import IPALintCore

@Suite("PayloadSizeLintRule Tests")
struct PayloadSizeLintRuleTests {
    @Test("Rule has correct descriptor")
    func ruleDescriptor() {
        // Given
        let fileSystem = MockFileSystem()
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)

        // When/Then
        #expect(subject.descriptor.identifier.rawValue == "payload_size")
        #expect(subject.descriptor.name == "Payload directory size")
        #expect(!subject.descriptor.description.isEmpty)
    }

    @Test("No violations when no configuration")
    func noViolationsWithoutConfiguration() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 50 << 20) // 50 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when directory size is below maxSize")
    func noViolationsWithSizeBelowMax() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 50 << 20) // 50 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when directory size equals maxSize")
    func noViolationsWithSizeEqualToMax() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 100 << 20) // 100 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when directory size exceeds maxSize")
    func violationWithSizeExceedingMax() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 150 << 20) // 150 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("bigger than max_size"))
        #expect(result.violations[0].message.contains("max_size=100.00 MB"))
        #expect(result.violations[0].message.contains("payload_size=150.00 MB"))
    }

    @Test("No violations when directory size is above minSize")
    func noViolationsWithSizeAboveMin() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 50 << 20) // 50 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minSize: FileSize(bytes: 10 << 20)) // 10 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when directory size equals minSize")
    func noViolationsWithSizeEqualToMin() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 10 << 20) // 10 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minSize: FileSize(bytes: 10 << 20)) // 10 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when directory size is below minSize")
    func violationWithSizeBelowMin() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 5 << 20) // 5 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minSize: FileSize(bytes: 10 << 20)) // 10 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("smaller than min_size"))
        #expect(result.violations[0].message.contains("min_size=10.00 MB"))
        #expect(result.violations[0].message.contains("payload_size=5.00 MB"))
    }

    @Test("No violations when size is within min and max range")
    func noViolationsWithinRange() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 50 << 20) // 50 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            minSize: FileSize(bytes: 10 << 20), // 10 MB
            maxSize: FileSize(bytes: 100 << 20), // 100 MB
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when size is below min in configured range")
    func violationBelowMinInRange() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 5 << 20) // 5 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            minSize: FileSize(bytes: 10 << 20), // 10 MB
            maxSize: FileSize(bytes: 100 << 20), // 100 MB
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("smaller than min_size"))
    }

    @Test("Violation when size is above max in configured range")
    func violationAboveMaxInRange() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 150 << 20) // 150 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            minSize: FileSize(bytes: 10 << 20), // 10 MB
            maxSize: FileSize(bytes: 100 << 20), // 100 MB
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("bigger than max_size"))
    }

    @Test("Warning severity when configured as warning")
    func warningSeverity() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 150 << 20) // 150 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.warning = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .warning)
    }

    @Test("Error configuration takes precedence over warning")
    func errorTakesPrecedenceOverWarning() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 150 << 20) // 150 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.warning = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        subject.configuration.error = .init(maxSize: FileSize(bytes: 100 << 20)) // 100 MB
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
    }

    @Test("FileSystem is called with correct path")
    func fileSystemCalledWithCorrectPath() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 50 << 20) // 50 MB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        let content = try makeContent()

        // When
        _ = try subject.lint(with: content)

        // Then
        #expect(fileSystem.lastDirectorySizePath == content.payloadPath)
    }

    @Test("Works with very small directory sizes")
    func worksWithSmallSizes() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 100) // 100 bytes
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            minSize: FileSize(bytes: 50),
            maxSize: FileSize(bytes: 1000),
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Works with very large directory sizes")
    func worksWithLargeSizes() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 5 << 30) // 5 GB
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            minSize: FileSize(bytes: 1 << 30), // 1 GB
            maxSize: FileSize(bytes: 10 << 30), // 10 GB
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Zero directory size is handled correctly")
    func zeroDirectorySize() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.directorySizeToReturn = FileSize(bytes: 0)
        let subject = PayloadSizeLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minSize: FileSize(bytes: 100))
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("smaller than min_size"))
    }

    // MARK: - Private

    private func makeContent() throws -> Content {
        try Content(
            ipaPath: AbsolutePath(validating: "/tmp/test.ipa"),
            appPath: AbsolutePath(validating: "/tmp/test.app"),
            temporaryDirectory: PredefinedDirectory(path: AbsolutePath(validating: "/tmp")),
        )
    }
}

// MARK: - Mock

private final class MockFileSystem: IPALintCore.FileSystem {
    var directorySizeToReturn: FileSize = .init(bytes: 0)
    var lastDirectorySizePath: AbsolutePath?

    var currentWorkingDirectory: AbsolutePath {
        // swiftlint:disable:next force_try
        try! AbsolutePath(validating: "/tmp")
    }

    func exists(at _: AbsolutePath) -> Bool {
        true
    }

    func move(from _: AbsolutePath, to _: AbsolutePath) throws {}

    func remove(at _: AbsolutePath) throws {}

    func list(at _: AbsolutePath) throws -> [FileSystemItem] {
        []
    }

    func tree(at path: AbsolutePath) throws -> FileSystemTree {
        FileSystemTree(path: path, items: [])
    }

    func createDirectory(at _: AbsolutePath) throws {}

    func executable(at _: AbsolutePath) -> Bool {
        false
    }

    func makeTemporaryDirectory() throws -> TemporaryDirectory {
        try TemporaryDirectory()
    }

    func absolutePath(from string: String) throws -> AbsolutePath {
        try AbsolutePath(validating: string)
    }

    func fileSize(at _: AbsolutePath) throws -> FileSize {
        FileSize(bytes: 0)
    }

    func directorySize(at path: AbsolutePath) throws -> FileSize {
        lastDirectorySizePath = path
        return directorySizeToReturn
    }

    func temporaryDirectory(at existingPath: AbsolutePath?) throws -> Directory {
        if let existingPath {
            guard exists(at: existingPath) else {
                throw CoreError.generic("Path does not exist")
            }
            return PredefinedDirectory(path: existingPath)
        }
        return try makeTemporaryDirectory()
    }

    func write(data _: Data, to _: AbsolutePath) throws {}

    func read(from _: AbsolutePath) throws -> Data {
        Data()
    }
}
