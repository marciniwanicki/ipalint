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
import TSCUtility

@testable import IPALintCore

@Suite("SnapshotParser Basic Tests")
struct SnapshotParserBasicTests {
    private let fileSystem = DefaultFileSystem()

    @Test("Write snapshot with single file")
    func writeSingleFile() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date()
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: createdAt,
            sha256: "abc123",
        )
        let file = try Snapshot.File(
            path: RelativePath(validating: "app/file.txt"),
            sha256: "def456",
            size: FileSize(bytes: 1024),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        #expect(fileSystem.exists(at: outputPath))

        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json != nil)
        #expect(json?["version"] as? String == "0.1.0")

        let descriptorJSON = json?["descriptor"] as? [String: Any]
        #expect(descriptorJSON?["filename"] as? String == "test.ipa")
        #expect(descriptorJSON?["sha256"] as? String == "abc123")

        let filesJSON = json?["files"] as? [[String: Any]]
        #expect(filesJSON?.count == 1)
        #expect(filesJSON?[0]["path"] as? String == "app/file.txt")
        #expect(filesJSON?[0]["sha256"] as? String == "def456")
        #expect(filesJSON?[0]["size"] as? UInt64 == 1024)
    }

    @Test("Write snapshot with multiple files")
    func writeMultipleFiles() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let files = try [
            Snapshot.File(
                path: RelativePath(validating: "app/file1.txt"),
                sha256: "hash1",
                size: FileSize(bytes: 100),
            ),
            Snapshot.File(
                path: RelativePath(validating: "app/file2.txt"),
                sha256: "hash2",
                size: FileSize(bytes: 200),
            ),
            Snapshot.File(
                path: RelativePath(validating: "app/dir/file3.txt"),
                sha256: "hash3",
                size: FileSize(bytes: 300),
            ),
        ]
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: files,
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        #expect(fileSystem.exists(at: outputPath))

        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let filesJSON = json?["files"] as? [[String: Any]]

        #expect(filesJSON?.count == 3)
        #expect(filesJSON?[0]["path"] as? String == "app/file1.txt")
        #expect(filesJSON?[1]["path"] as? String == "app/file2.txt")
        #expect(filesJSON?[2]["path"] as? String == "app/dir/file3.txt")
    }

    @Test("Write snapshot with empty files array")
    func writeEmptyFiles() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        #expect(fileSystem.exists(at: outputPath))

        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let filesJSON = json?["files"] as? [[String: Any]]

        #expect(filesJSON?.isEmpty == true)
    }

    @Test("Write snapshot with pretty printed JSON")
    func writePrettyPrintedJSON() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let file = try Snapshot.File(
            path: RelativePath(validating: "app/file.txt"),
            sha256: "def456",
            size: FileSize(bytes: 1024),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let jsonString = String(data: data, encoding: .utf8)

        #expect(jsonString != nil)
        // Pretty printed JSON should contain newlines and indentation
        #expect(jsonString?.contains("\n") == true)
        #expect(jsonString?.contains("  ") == true) // Indentation
    }

    @Test("Write snapshot preserves date precision")
    func writeDatePrecision() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date()
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: createdAt,
            sha256: "abc123",
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DecodableSnapshot.self, from: data)

        // Dates should be close (allow 1 second difference due to encoding precision)
        let timeDifference = abs(decoded.descriptor.createdAt.timeIntervalSince(createdAt))
        #expect(timeDifference < 1.0)
    }
}

@Suite("SnapshotParser Advanced Tests")
struct SnapshotParserAdvancedTests {
    private let fileSystem = DefaultFileSystem()

    @Test("Write snapshot with different version numbers")
    func writeVersionNumbers() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let snapshot = Snapshot(
            version: Version(1, 2, 3),
            descriptor: descriptor,
            files: [],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["version"] as? String == "1.2.3")
    }

    @Test("Write snapshot with special characters in paths")
    func writeSpecialCharactersInPaths() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test with spaces.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let file = try Snapshot.File(
            path: RelativePath(validating: "app/file with spaces.txt"),
            sha256: "def456",
            size: FileSize(bytes: 1024),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let descriptorJSON = json?["descriptor"] as? [String: Any]
        let filesJSON = json?["files"] as? [[String: Any]]

        #expect(descriptorJSON?["filename"] as? String == "test with spaces.ipa")
        #expect(filesJSON?[0]["path"] as? String == "app/file with spaces.txt")
    }

    @Test("Write snapshot with large file sizes")
    func writeLargeFileSizes() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let largeSize: UInt64 = 10_000_000_000 // 10 GB
        let file = try Snapshot.File(
            path: RelativePath(validating: "app/large.bin"),
            sha256: "def456",
            size: FileSize(bytes: largeSize),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let filesJSON = json?["files"] as? [[String: Any]]

        #expect(filesJSON?[0]["size"] as? UInt64 == largeSize)
    }

    @Test("Write snapshot with nested directory paths")
    func writeNestedPaths() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(),
            sha256: "abc123",
        )
        let file = try Snapshot.File(
            path: RelativePath(validating: "a/b/c/d/e/file.txt"),
            sha256: "def456",
            size: FileSize(bytes: 1024),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let data = try fileSystem.read(from: outputPath)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let filesJSON = json?["files"] as? [[String: Any]]

        #expect(filesJSON?[0]["path"] as? String == "a/b/c/d/e/file.txt")
    }
}

// Helper struct for decoding snapshot to verify date precision
private struct DecodableSnapshot: Decodable {
    struct Descriptor: Decodable {
        let filename: String
        let createdAt: Date
        let sha256: String
    }

    let version: String
    let descriptor: Descriptor
}
