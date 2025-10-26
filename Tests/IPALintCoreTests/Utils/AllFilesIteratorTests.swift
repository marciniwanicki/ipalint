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

@Suite("AllFilesIterator Tests")
struct AllFilesIteratorTests {
    @Test("Empty tree returns no files")
    func emptyTree() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let tree = FileSystemTree(path: rootPath, items: [])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.isEmpty)
    }

    @Test("Tree with single file at root")
    func singleFileAtRoot() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file = try FileSystemTree.File(path: RelativePath(validating: "file.txt"))
        let tree = FileSystemTree(path: rootPath, items: [.file(file)])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 1)
        #expect(files[0].pathString == "/tmp/test/file.txt")
    }

    @Test("Tree with multiple files at root")
    func multipleFilesAtRoot() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file1 = try FileSystemTree.File(path: RelativePath(validating: "file1.txt"))
        let file2 = try FileSystemTree.File(path: RelativePath(validating: "file2.txt"))
        let file3 = try FileSystemTree.File(path: RelativePath(validating: "file3.txt"))
        let tree = FileSystemTree(path: rootPath, items: [
            .file(file1),
            .file(file2),
            .file(file3),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 3)
        #expect(files.contains(where: { $0.pathString == "/tmp/test/file1.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/file2.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/file3.txt" }))
    }

    @Test("Tree with nested directory containing files")
    func nestedDirectory() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file1 = try FileSystemTree.File(path: RelativePath(validating: "file1.txt"))
        let file2 = try FileSystemTree.File(path: RelativePath(validating: "file2.txt"))
        let dir = try FileSystemTree.Directory(
            path: RelativePath(validating: "subdir"),
            items: [
                .file(file1),
                .file(file2),
            ],
        )
        let tree = FileSystemTree(path: rootPath, items: [.directory(dir)])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 2)
        #expect(files.contains(where: { $0.pathString == "/tmp/test/subdir/file1.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/subdir/file2.txt" }))
    }

    @Test("Tree with mixed files and directories")
    func mixedFilesAndDirectories() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let rootFile = try FileSystemTree.File(path: RelativePath(validating: "root.txt"))
        let nestedFile = try FileSystemTree.File(path: RelativePath(validating: "nested.txt"))
        let dir = try FileSystemTree.Directory(
            path: RelativePath(validating: "subdir"),
            items: [.file(nestedFile)],
        )
        let tree = FileSystemTree(path: rootPath, items: [
            .file(rootFile),
            .directory(dir),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 2)
        #expect(files.contains(where: { $0.pathString == "/tmp/test/root.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/subdir/nested.txt" }))
    }

    @Test("Tree with deeply nested directories")
    func deeplyNestedDirectories() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let deepFile = try FileSystemTree.File(path: RelativePath(validating: "deep.txt"))
        let level3 = try FileSystemTree.Directory(
            path: RelativePath(validating: "level3"),
            items: [.file(deepFile)],
        )
        let level2 = try FileSystemTree.Directory(
            path: RelativePath(validating: "level2"),
            items: [.directory(level3)],
        )
        let level1 = try FileSystemTree.Directory(
            path: RelativePath(validating: "level1"),
            items: [.directory(level2)],
        )
        let tree = FileSystemTree(path: rootPath, items: [.directory(level1)])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 1)
        #expect(files[0].pathString == "/tmp/test/level1/level2/level3/deep.txt")
    }

    @Test("Tree with empty directories")
    func emptyDirectories() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let emptyDir1 = try FileSystemTree.Directory(
            path: RelativePath(validating: "empty1"),
            items: [],
        )
        let emptyDir2 = try FileSystemTree.Directory(
            path: RelativePath(validating: "empty2"),
            items: [],
        )
        let tree = FileSystemTree(path: rootPath, items: [
            .directory(emptyDir1),
            .directory(emptyDir2),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.isEmpty)
    }

    @Test("ForEach iterates over all files")
    func forEachIteration() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file1 = try FileSystemTree.File(path: RelativePath(validating: "file1.txt"))
        let file2 = try FileSystemTree.File(path: RelativePath(validating: "file2.txt"))
        let tree = FileSystemTree(path: rootPath, items: [
            .file(file1),
            .file(file2),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        var collectedPaths: [AbsolutePath] = []
        // swiftformat:disable:next preferForLoop
        subject.forEach { path in
            collectedPaths.append(path)
        }

        // Then
        #expect(collectedPaths.count == 2)
        #expect(collectedPaths.contains(where: { $0.pathString == "/tmp/test/file1.txt" }))
        #expect(collectedPaths.contains(where: { $0.pathString == "/tmp/test/file2.txt" }))
    }

    @Test("ForEach with nested structure")
    func forEachNested() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let rootFile = try FileSystemTree.File(path: RelativePath(validating: "root.txt"))
        let nestedFile = try FileSystemTree.File(path: RelativePath(validating: "nested.txt"))
        let dir = try FileSystemTree.Directory(
            path: RelativePath(validating: "subdir"),
            items: [.file(nestedFile)],
        )
        let tree = FileSystemTree(path: rootPath, items: [
            .file(rootFile),
            .directory(dir),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        var collectedPaths: [AbsolutePath] = []
        // swiftformat:disable:next preferForLoop
        subject.forEach { path in
            collectedPaths.append(path)
        }

        // Then
        #expect(collectedPaths.count == 2)
        #expect(collectedPaths.contains(where: { $0.pathString == "/tmp/test/root.txt" }))
        #expect(collectedPaths.contains(where: { $0.pathString == "/tmp/test/subdir/nested.txt" }))
    }

    @Test("Extension method creates iterator")
    func extensionMethod() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file = try FileSystemTree.File(path: RelativePath(validating: "file.txt"))
        let tree = FileSystemTree(path: rootPath, items: [.file(file)])

        // When
        let iterator = tree.allFilesIterator()
        let files = iterator.all()

        // Then
        #expect(files.count == 1)
        #expect(files[0].pathString == "/tmp/test/file.txt")
    }

    @Test("Complex tree structure with multiple levels")
    func complexTreeStructure() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")

        // Create a complex structure:
        // root.txt
        // dir1/
        //   file1.txt
        //   file2.txt
        //   subdir1/
        //     nested1.txt
        // dir2/
        //   file3.txt

        let rootFile = try FileSystemTree.File(path: RelativePath(validating: "root.txt"))
        let file1 = try FileSystemTree.File(path: RelativePath(validating: "file1.txt"))
        let file2 = try FileSystemTree.File(path: RelativePath(validating: "file2.txt"))
        let nested1 = try FileSystemTree.File(path: RelativePath(validating: "nested1.txt"))
        let file3 = try FileSystemTree.File(path: RelativePath(validating: "file3.txt"))

        let subdir1 = try FileSystemTree.Directory(
            path: RelativePath(validating: "subdir1"),
            items: [.file(nested1)],
        )

        let dir1 = try FileSystemTree.Directory(
            path: RelativePath(validating: "dir1"),
            items: [
                .file(file1),
                .file(file2),
                .directory(subdir1),
            ],
        )

        let dir2 = try FileSystemTree.Directory(
            path: RelativePath(validating: "dir2"),
            items: [.file(file3)],
        )

        let tree = FileSystemTree(path: rootPath, items: [
            .file(rootFile),
            .directory(dir1),
            .directory(dir2),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let files = subject.all()

        // Then
        #expect(files.count == 5)
        #expect(files.contains(where: { $0.pathString == "/tmp/test/root.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/dir1/file1.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/dir1/file2.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/dir1/subdir1/nested1.txt" }))
        #expect(files.contains(where: { $0.pathString == "/tmp/test/dir2/file3.txt" }))
    }

    @Test("All method and forEach produce same results")
    func allAndForEachConsistent() throws {
        // Given
        let rootPath = try AbsolutePath(validating: "/tmp/test")
        let file1 = try FileSystemTree.File(path: RelativePath(validating: "file1.txt"))
        let file2 = try FileSystemTree.File(path: RelativePath(validating: "file2.txt"))
        let nestedFile = try FileSystemTree.File(path: RelativePath(validating: "nested.txt"))
        let dir = try FileSystemTree.Directory(
            path: RelativePath(validating: "subdir"),
            items: [.file(nestedFile)],
        )
        let tree = FileSystemTree(path: rootPath, items: [
            .file(file1),
            .file(file2),
            .directory(dir),
        ])
        let subject = AllFilesIterator(fileSystemTree: tree)

        // When
        let allFiles = subject.all()
        var forEachFiles: [AbsolutePath] = []
        // swiftformat:disable:next preferForLoop
        subject.forEach { path in
            forEachFiles.append(path)
        }

        // Then
        #expect(allFiles.count == forEachFiles.count)
        #expect(Set(allFiles.map(\.pathString)) == Set(forEachFiles.map(\.pathString)))
    }
}
