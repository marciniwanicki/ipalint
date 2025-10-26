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

@Suite("FileSystem Tests")
struct FileSystemTests {
    private let subject = DefaultFileSystem()
    private let fileManager = FileManager.default

    @Test("Exists returns true for existing file")
    func existsForExistingFile() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let testFile = tempDir.path.appending(component: "test.txt")
        try subject.write(data: Data("test".utf8), to: testFile)

        // When
        let exists = subject.exists(at: testFile)

        // Then
        #expect(exists == true)
    }

    @Test("Exists returns false for non-existent file")
    func existsForNonExistentFile() throws {
        // Given
        let nonExistentPath = try AbsolutePath(validating: "/tmp/nonexistent-\(UUID().uuidString).txt")

        // When
        let exists = subject.exists(at: nonExistentPath)

        // Then
        #expect(exists == false)
    }

    @Test("Write and read data from file")
    func writeAndReadData() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let testFile = tempDir.path.appending(component: "test.txt")
        let testData = Data("Hello, World!".utf8)

        // When
        try subject.write(data: testData, to: testFile)
        let readData = try subject.read(from: testFile)

        // Then
        #expect(readData == testData)
    }

    @Test("Create directory creates directory structure")
    func createDirectory() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let nestedDir = tempDir.path.appending(components: "a", "b", "c")

        // When
        try subject.createDirectory(at: nestedDir)

        // Then
        #expect(subject.exists(at: nestedDir))
    }

    @Test("Move file to new location")
    func moveFile() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let sourceFile = tempDir.path.appending(component: "source.txt")
        let destFile = tempDir.path.appending(component: "dest.txt")
        try subject.write(data: Data("content".utf8), to: sourceFile)

        // When
        try subject.move(from: sourceFile, to: destFile)

        // Then
        #expect(subject.exists(at: destFile))
        #expect(!subject.exists(at: sourceFile))
    }

    @Test("Remove file deletes file")
    func removeFile() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let testFile = tempDir.path.appending(component: "test.txt")
        try subject.write(data: Data("test".utf8), to: testFile)

        // When
        try subject.remove(at: testFile)

        // Then
        #expect(!subject.exists(at: testFile))
    }

    @Test("List returns files and directories")
    func listContents() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let file1 = tempDir.path.appending(component: "file1.txt")
        let file2 = tempDir.path.appending(component: "file2.txt")
        let dir1 = tempDir.path.appending(component: "dir1")

        try subject.write(data: Data("test".utf8), to: file1)
        try subject.write(data: Data("test".utf8), to: file2)
        try subject.createDirectory(at: dir1)

        // When
        let items = try subject.list(at: tempDir.path)

        // Then
        #expect(items.count == 3)

        let files = items.compactMap { item -> String? in
            if case let .file(file) = item {
                return file.path.pathString
            }
            return nil
        }
        let directories = items.compactMap { item -> String? in
            if case let .directory(dir) = item {
                return dir.path.pathString
            }
            return nil
        }

        #expect(files.count == 2)
        #expect(directories.count == 1)
        #expect(files.contains("file1.txt"))
        #expect(files.contains("file2.txt"))
        #expect(directories.contains("dir1"))
    }

    @Test("Tree returns recursive directory structure")
    func treeStructure() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        // Create structure: root/file1.txt, root/dir1/file2.txt, root/dir1/dir2/file3.txt
        let file1 = tempDir.path.appending(component: "file1.txt")
        let dir1 = tempDir.path.appending(component: "dir1")
        let file2 = dir1.appending(component: "file2.txt")
        let dir2 = dir1.appending(component: "dir2")
        let file3 = dir2.appending(component: "file3.txt")

        try subject.write(data: Data("1".utf8), to: file1)
        try subject.createDirectory(at: dir1)
        try subject.write(data: Data("2".utf8), to: file2)
        try subject.createDirectory(at: dir2)
        try subject.write(data: Data("3".utf8), to: file3)

        // When
        let tree = try subject.tree(at: tempDir.path)

        // Then
        #expect(tree.path == tempDir.path)
        #expect(tree.items.count == 2) // file1.txt and dir1

        // Verify the tree contains the expected structure
        var hasFile1 = false
        var hasDir1 = false

        for item in tree.items {
            switch item {
            case let .file(file):
                if file.path.pathString == "file1.txt" {
                    hasFile1 = true
                }
            case let .directory(dir):
                if dir.path.pathString == "dir1" {
                    hasDir1 = true
                    #expect(dir.items.count == 2) // file2.txt and dir2
                }
            }
        }

        #expect(hasFile1)
        #expect(hasDir1)
    }

    @Test("File size returns correct size")
    func fileSize() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let testFile = tempDir.path.appending(component: "test.txt")
        let testData = Data(repeating: 0x42, count: 1024) // 1 KB
        try subject.write(data: testData, to: testFile)

        // When
        let size = try subject.fileSize(at: testFile)

        // Then
        #expect(size.bytes == 1024)
    }

    @Test("Directory size calculates total size recursively")
    func directorySize() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let file1 = tempDir.path.appending(component: "file1.txt")
        let dir1 = tempDir.path.appending(component: "dir1")
        let file2 = dir1.appending(component: "file2.txt")

        try subject.write(data: Data(repeating: 0x41, count: 100), to: file1) // 100 bytes
        try subject.createDirectory(at: dir1)
        try subject.write(data: Data(repeating: 0x42, count: 200), to: file2) // 200 bytes

        // When
        let size = try subject.directorySize(at: tempDir.path)

        // Then
        #expect(size.bytes == 300) // 100 + 200
    }

    @Test("Absolute path from absolute string")
    func absolutePathFromAbsolute() throws {
        // Given
        let absoluteString = "/tmp/test.txt"

        // When
        let path = try subject.absolutePath(from: absoluteString)

        // Then
        #expect(path.pathString == absoluteString)
    }

    @Test("Absolute path from relative string")
    func absolutePathFromRelative() throws {
        // Given
        let relativeString = "test.txt"

        // When
        let path = try subject.absolutePath(from: relativeString)

        // Then
        #expect(path.pathString.contains("test.txt"))
        #expect(path.pathString.hasPrefix("/"))
    }

    @Test("Executable returns true for executable file")
    func executableFile() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let scriptFile = tempDir.path.appending(component: "script.sh")
        try subject.write(data: Data("#!/bin/bash\necho test".utf8), to: scriptFile)
        try fileManager.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: scriptFile.pathString,
        )

        // When
        let isExecutable = subject.executable(at: scriptFile)

        // Then
        #expect(isExecutable == true)
    }

    @Test("Executable returns false for non-executable file")
    func nonExecutableFile() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let textFile = tempDir.path.appending(component: "text.txt")
        try subject.write(data: Data("test".utf8), to: textFile)

        // When
        let isExecutable = subject.executable(at: textFile)

        // Then
        #expect(isExecutable == false)
    }

    @Test("Make temporary directory creates new directory")
    func makeTemporaryDirectory() throws {
        // Given/When
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        // Then
        #expect(subject.exists(at: tempDir.path))
    }

    @Test("Temporary directory with existing empty path uses that path")
    func temporaryDirectoryExistingEmpty() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let emptyDir = tempDir.path.appending(component: "empty")
        try subject.createDirectory(at: emptyDir)

        // When
        let directory = try subject.temporaryDirectory(at: emptyDir)

        // Then
        #expect(directory.path == emptyDir)
    }

    @Test("Temporary directory with non-empty path throws error")
    func temporaryDirectoryNonEmpty() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        let nonEmptyDir = tempDir.path.appending(component: "nonempty")
        try subject.createDirectory(at: nonEmptyDir)
        let testFile = nonEmptyDir.appending(component: "test.txt")
        try subject.write(data: Data("test".utf8), to: testFile)

        // When/Then
        #expect(throws: CoreError.self) {
            _ = try subject.temporaryDirectory(at: nonEmptyDir)
        }
    }

    @Test("Temporary directory with nil path creates new directory")
    func temporaryDirectoryNilPath() throws {
        // When
        let directory = try subject.temporaryDirectory(at: nil)
        defer { try? subject.remove(at: directory.path) }

        // Then
        #expect(subject.exists(at: directory.path))
    }

    @Test("Current working directory returns valid path")
    func currentWorkingDirectory() {
        // When
        let cwd = subject.currentWorkingDirectory

        // Then
        #expect(cwd.pathString.hasPrefix("/"))
        #expect(subject.exists(at: cwd))
    }

    @Test("List empty directory returns empty array")
    func listEmptyDirectory() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        // When
        let items = try subject.list(at: tempDir.path)

        // Then
        #expect(items.isEmpty)
    }

    @Test("Tree of empty directory has no items")
    func treeEmptyDirectory() throws {
        // Given
        let tempDir = try subject.makeTemporaryDirectory()
        defer { try? subject.remove(at: tempDir.path) }

        // When
        let tree = try subject.tree(at: tempDir.path)

        // Then
        #expect(tree.items.isEmpty)
    }
}
