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

@Suite("PredefinedDirectory Tests")
struct PredefinedDirectoryTests {
    @Test("Initialize with absolute path")
    func initializeWithAbsolutePath() throws {
        // Given
        let path = try AbsolutePath(validating: "/tmp/test")

        // When
        let subject = PredefinedDirectory(path: path)

        // Then
        #expect(subject.path == path)
    }

    @Test("Path property returns initialized path")
    func pathProperty() throws {
        // Given
        let expectedPath = try AbsolutePath(validating: "/usr/local/bin")
        let subject = PredefinedDirectory(path: expectedPath)

        // When
        let actualPath = subject.path

        // Then
        #expect(actualPath == expectedPath)
    }

    @Test("Conforms to Directory protocol")
    func conformsToDirectory() throws {
        // Given
        let path = try AbsolutePath(validating: "/tmp/test")
        let subject = PredefinedDirectory(path: path)

        // When
        let directory: Directory = subject

        // Then
        #expect(directory.path == path)
    }
}

@Suite("TemporaryDirectory Tests")
struct TemporaryDirectoryTests {
    private let fileManager = FileManager.default

    @Test("Creates temporary directory")
    func createsTemporaryDirectory() throws {
        // Given/When
        let subject = try TemporaryDirectory()

        // Then
        #expect(fileManager.fileExists(atPath: subject.path.pathString))
    }

    @Test("Path contains ipalint prefix")
    func pathContainsPrefix() throws {
        // Given/When
        let subject = try TemporaryDirectory()

        // Then
        #expect(subject.path.pathString.contains("ipalint"))
    }

    @Test("Creates unique directory each time")
    func createsUniqueDirectory() throws {
        // Given/When
        let subject1 = try TemporaryDirectory()
        let subject2 = try TemporaryDirectory()

        // Then
        #expect(subject1.path != subject2.path)
    }

    @Test("Directory is writable")
    func directoryIsWritable() throws {
        // Given
        let subject = try TemporaryDirectory()
        let testFile = subject.path.appending(component: "test.txt")

        // When
        let testData = Data("test content".utf8)
        try testData.write(to: URL(fileURLWithPath: testFile.pathString))

        // Then
        #expect(fileManager.fileExists(atPath: testFile.pathString))
    }

    @Test("Cleans up directory on deallocation")
    func cleansUpOnDeallocation() throws {
        // Given
        var path: AbsolutePath?
        do {
            let subject = try TemporaryDirectory()
            path = subject.path
            #expect(fileManager.fileExists(atPath: path!.pathString))
        }

        // When - subject is deallocated here

        // Then
        #expect(!fileManager.fileExists(atPath: path!.pathString))
    }

    @Test("Cleans up directory with files on deallocation")
    func cleansUpDirectoryWithFiles() throws {
        // Given
        var path: AbsolutePath?
        do {
            let subject = try TemporaryDirectory()
            path = subject.path

            // Create some files in the directory
            let file1 = subject.path.appending(component: "file1.txt")
            let file2 = subject.path.appending(component: "file2.txt")
            try Data("content1".utf8).write(to: URL(fileURLWithPath: file1.pathString))
            try Data("content2".utf8).write(to: URL(fileURLWithPath: file2.pathString))

            #expect(fileManager.fileExists(atPath: path!.pathString))
        }

        // When - subject is deallocated here

        // Then
        #expect(!fileManager.fileExists(atPath: path!.pathString))
    }

    @Test("Directory path is absolute")
    func directoryPathIsAbsolute() throws {
        // Given/When
        let subject = try TemporaryDirectory()

        // Then
        #expect(subject.path.pathString.hasPrefix("/"))
    }

    @Test("Conforms to Directory protocol")
    func conformsToDirectory() throws {
        // Given/When
        let subject = try TemporaryDirectory()

        // Then
        let directory: Directory = subject
        #expect(directory.path == subject.path)
    }

    @Test("Can create nested directories")
    func createNestedDirectories() throws {
        // Given
        let subject = try TemporaryDirectory()
        let nestedDir = subject.path.appending(components: "a", "b", "c")

        // When
        try fileManager.createDirectory(
            atPath: nestedDir.pathString,
            withIntermediateDirectories: true,
        )

        // Then
        #expect(fileManager.fileExists(atPath: nestedDir.pathString))
    }

    @Test("Multiple instances don't interfere")
    func multipleInstancesDontInterfere() throws {
        // Given/When
        let subject1 = try TemporaryDirectory()
        let subject2 = try TemporaryDirectory()

        let file1 = subject1.path.appending(component: "test1.txt")
        let file2 = subject2.path.appending(component: "test2.txt")

        try Data("content1".utf8).write(to: URL(fileURLWithPath: file1.pathString))
        try Data("content2".utf8).write(to: URL(fileURLWithPath: file2.pathString))

        // Then
        #expect(fileManager.fileExists(atPath: file1.pathString))
        #expect(fileManager.fileExists(atPath: file2.pathString))
        #expect(!fileManager.fileExists(atPath: subject1.path.appending(component: "test2.txt").pathString))
        #expect(!fileManager.fileExists(atPath: subject2.path.appending(component: "test1.txt").pathString))
    }
}
