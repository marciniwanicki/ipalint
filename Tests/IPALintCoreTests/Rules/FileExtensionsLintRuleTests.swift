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

@Suite("FileExtensionsLintRule Tests")
struct FileExtensionsLintRuleTests {
    @Test("Rule has correct descriptor")
    func ruleDescriptor() {
        // Given
        let subject = FileExtensionsLintRule()

        // When/Then
        #expect(subject.descriptor.identifier.rawValue == "file_extensions")
        #expect(subject.descriptor.name == "File extensions")
        #expect(!subject.descriptor.description.isEmpty)
    }

    @Test("No violations when no configuration")
    func noViolationsWithoutConfiguration() throws {
        // Given
        let subject = FileExtensionsLintRule()
        let tree = try makeFileSystemTree(files: [
            "test.txt",
            "test.png",
            "test.json",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when all extensions are in expectOnly list")
    func noViolationsWithAllExpectedExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt", "png"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.png",
            "file3.txt",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when file has unexpected extension")
    func violationWithUnexpectedExtension() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt", "png"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.json",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("unexpected estension"))
        #expect(result.violations[0].message.contains("extension=json"))
        #expect(result.violations[0].message.contains("path=file2.json"))
    }

    @Test("Multiple violations for multiple unexpected extensions")
    func multipleViolationsWithUnexpectedExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.json",
            "file3.xml",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 2)
        #expect(result.violations.allSatisfy { $0.severity == .error })
    }

    @Test("No violations when no forbidden extensions found")
    func noViolationsWithoutForbiddenExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(forbidden: ["log", "tmp"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.png",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when file has forbidden extension")
    func violationWithForbiddenExtension() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(forbidden: ["log", "tmp"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.log",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("forbidden extension"))
        #expect(result.violations[0].message.contains("extension=log"))
        #expect(result.violations[0].message.contains("path=file2.log"))
    }

    @Test("Multiple violations for multiple forbidden extensions")
    func multipleViolationsWithForbiddenExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(forbidden: ["log", "tmp"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.log",
            "file3.tmp",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 2)
        #expect(result.violations.allSatisfy { $0.severity == .error })
    }

    @Test("Warning severity when configured as warning")
    func warningSeverity() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.warning = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.json",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .warning)
    }

    @Test("Error configuration takes precedence over warning")
    func errorTakesPrecedenceOverWarning() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.warning = .init(expectOnly: ["txt"])
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "file1.json",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
    }

    @Test("No violations for files without extensions")
    func noViolationsForFilesWithoutExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "Makefile",
            "README",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Both expectOnly and forbidden can be used together")
    func bothExpectOnlyAndForbidden() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(
            expectOnly: ["txt", "png", "json"],
            forbidden: ["json"],
        )
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.json",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("forbidden extension"))
        #expect(result.violations[0].message.contains("extension=json"))
    }

    @Test("Handles nested directory structure")
    func handlesNestedDirectories() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "dir1/file1.txt",
            "dir1/dir2/file2.json",
            "dir3/file3.txt",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("extension=json"))
        #expect(result.violations[0].message.contains("path=dir1/dir2/file2.json"))
    }

    @Test("Empty file system tree produces no violations")
    func emptyTreeNoViolations() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Case sensitive extension matching")
    func caseSensitiveExtensions() throws {
        // Given
        let subject = FileExtensionsLintRule()
        subject.configuration.error = .init(expectOnly: ["txt"])
        let tree = try makeFileSystemTree(files: [
            "file1.txt",
            "file2.TXT",
        ])

        // When
        let result = try subject.lint(with: tree)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].message.contains("extension=TXT"))
    }

    // MARK: - Private

    private func makeFileSystemTree(files: [String]) throws -> FileSystemTree {
        let basePath = try AbsolutePath(validating: "/tmp/test")

        // Build a tree structure
        let root = TreeNode(name: "", isDirectory: true)

        for file in files {
            let components = file.split(separator: "/").map(String.init)
            var currentNode = root

            for (index, component) in components.enumerated() {
                let isLastComponent = index == components.count - 1
                let isDirectory = !isLastComponent

                if let existingChild = currentNode.children.first(where: { $0.name == component }) {
                    currentNode = existingChild
                } else {
                    let newNode = TreeNode(name: component, isDirectory: isDirectory)
                    currentNode.children.append(newNode)
                    currentNode = newNode
                }
            }
        }

        let items = try buildItems(from: root.children)
        return FileSystemTree(path: basePath, items: items)
    }

    private func buildItems(from nodes: [TreeNode]) throws -> [FileSystemTree.Item] {
        var items: [FileSystemTree.Item] = []

        for node in nodes {
            if node.isDirectory {
                let dirPath = try RelativePath(validating: node.name)
                let dirItems = try buildItems(from: node.children)
                items.append(.directory(FileSystemTree.Directory(
                    path: dirPath,
                    items: dirItems,
                )))
            } else {
                let filePath = try RelativePath(validating: node.name)
                items.append(.file(FileSystemTree.File(path: filePath)))
            }
        }

        return items
    }

    private class TreeNode {
        let name: String
        let isDirectory: Bool
        var children: [TreeNode] = []

        init(name: String, isDirectory: Bool) {
            self.name = name
            self.isDirectory = isDirectory
        }
    }
}
