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
// swiftlint:disable file_length
import Foundation
import Testing
import TSCBasic

@testable import IPALintCore

@Suite("FrameworksLintRule Tests")
struct FrameworksLintRuleTests {
    @Test("Rule has correct descriptor")
    func ruleDescriptor() {
        // Given
        let fileSystem = MockFileSystem()
        let subject = FrameworksLintRule(fileSystem: fileSystem)

        // When/Then
        #expect(subject.descriptor.identifier.rawValue == "frameworks")
        #expect(subject.descriptor.name == "Frameworks")
        #expect(!subject.descriptor.description.isEmpty)
    }

    @Test("No violations when no configuration")
    func noViolationsWithoutConfiguration() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when framework count is below maxCount")
    func noViolationsWithMaxCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(maxCount: 5)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when framework count exceeds maxCount")
    func violationWithExceededMaxCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(maxCount: 2)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Too many dynamic frameworks"))
        #expect(result.violations[0].message.contains("min_count=2"))
        #expect(result.violations[0].message.contains("frameworks_count=3"))
    }

    @Test("No violations when framework count is above minCount")
    func noViolationsWithMinCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minCount: 2)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when framework count is below minCount")
    func violationWithBelowMinCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(minCount: 3)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Too few dynamic frameworks"))
        #expect(result.violations[0].message.contains("max_count=3"))
        #expect(result.violations[0].message.contains("frameworks_count=1"))
    }

    @Test("No violations when framework count matches count")
    func noViolationsWithExactCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(count: 2)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when framework count does not match count")
    func violationWithMismatchedCount() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(count: 2)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Unexpected number of dynamic frameworks"))
        #expect(result.violations[0].message.contains("count=2"))
        #expect(result.violations[0].message.contains("frameworks_count=3"))
    }

    @Test("No violations when frameworks match list exactly")
    func noViolationsWithMatchingList() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(list: ["SwiftUI", "Combine"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when frameworks do not match list")
    func violationWithMismatchedList() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(list: ["SwiftUI", "Combine"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Unexpected dynamic framework(s)"))
        #expect(result.violations[0].message.contains("missing_frameworks=[\"Combine\"]"))
        #expect(result.violations[0].message.contains("unexpected_frameworks=[\"CoreData\"]"))
    }

    @Test("Violation when list has missing frameworks")
    func violationWithMissingFrameworksInList() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(list: ["SwiftUI", "Combine", "CoreData"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("missing_frameworks=[\"Combine\", \"CoreData\"]"))
        #expect(result.violations[0].message.contains("unexpected_frameworks=[]"))
    }

    @Test("No violations when frameworks exactly match include list")
    func noViolationsWithExactIncludeMatch() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(include: ["SwiftUI", "Combine"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when frameworks are superset of include list")
    func violationWithFrameworksSuperset() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(include: ["SwiftUI", "Combine"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        // Note: This tests current implementation behavior (isStrictSuperset check)
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Missing dynamic framework(s)"))
        #expect(result.violations[0].message.contains("missing_frameworks=[]"))
    }

    @Test("No violations when excluded frameworks are not present")
    func noViolationsWithoutExcludedFrameworks() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(exclude: ["DeprecatedFramework", "InsecureLibrary"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when excluded frameworks are present")
    func violationWithExcludedFrameworks() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "DeprecatedFramework"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(exclude: ["DeprecatedFramework", "InsecureLibrary"])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Found unexpected dynamic framework(s)"))
        #expect(result.violations[0].message.contains("unexpected_frameworks="))
        #expect(result.violations[0].message.contains("DeprecatedFramework"))
    }

    @Test("Warning severity when configured as warning")
    func warningSeverity() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.warning = .init(maxCount: 2)
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
        fileSystem.frameworksToReturn = ["SwiftUI", "Combine", "CoreData"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.warning = .init(maxCount: 2)
        subject.configuration.error = .init(maxCount: 2)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
    }

    @Test("No violations with empty frameworks directory")
    func noViolationsWithEmptyFrameworks() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = []
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Frameworks directory path is constructed correctly")
    func frameworksPathConstruction() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        let content = try makeContent()

        // When
        _ = try subject.lint(with: content)

        // Then
        let expectedPath = content.appPath.appending(component: "Frameworks")
        #expect(fileSystem.lastListedPath == expectedPath)
    }

    @Test("Multiple configuration violations can occur simultaneously")
    func multipleViolations() throws {
        // Given
        let fileSystem = MockFileSystem()
        fileSystem.frameworksToReturn = ["SwiftUI", "DeprecatedFramework"]
        let subject = FrameworksLintRule(fileSystem: fileSystem)
        subject.configuration.error = .init(
            maxCount: 1,
            exclude: ["DeprecatedFramework"],
        )
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 2)
        #expect(result.violations.allSatisfy { $0.severity == .error })
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
    var frameworksToReturn: [String] = []
    var lastListedPath: AbsolutePath?

    var currentWorkingDirectory: AbsolutePath {
        // swiftlint:disable:next force_try
        try! AbsolutePath(validating: "/tmp")
    }

    func exists(at _: AbsolutePath) -> Bool {
        true
    }

    func move(from _: AbsolutePath, to _: AbsolutePath) throws {}

    func remove(at _: AbsolutePath) throws {}

    func list(at path: AbsolutePath) throws -> [FileSystemItem] {
        lastListedPath = path
        return frameworksToReturn.map { framework in
            // swiftlint:disable:next force_try
            let frameworkPath = try! RelativePath(validating: "\(framework).framework")
            return .directory(FileSystemItem.Directory(path: frameworkPath))
        }
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

    func directorySize(at _: AbsolutePath) throws -> FileSize {
        FileSize(bytes: 0)
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
