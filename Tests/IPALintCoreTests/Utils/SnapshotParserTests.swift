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

@Suite("SnapshotParser Tests")
struct SnapshotParserTests {
    private let fileSystem = DefaultFileSystem()

    @Test("Write snapshot with single file")
    func writeSingleFile() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        // Use fixed date: 2009-02-13 23:31:30 UTC
        let createdAt = Date(timeIntervalSince1970: 1_234_567_890)
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

        let jsonString = try readJSONString(from: outputPath)

        let expectedJSON = """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test.ipa",
            "sha256" : "abc123"
          },
          "files" : [
            {
              "path" : "app\\/file.txt",
              "sha256" : "def456",
              "size" : 1024
            }
          ],
          "version" : "0.1.0"
        }
        """

        #expect(jsonString == expectedJSON)
    }

    @Test("Write snapshot with file array")
    func writeFileArray() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }
        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: Date(timeIntervalSince1970: 1_234_567_890),
            sha256: "abc123",
        )
        let file = try Snapshot.File(
            path: RelativePath(validating: "app/file.txt"),
            sha256: "hash1",
            size: FileSize(bytes: 100),
        )
        let snapshot = Snapshot(
            version: Version(0, 1, 0),
            descriptor: descriptor,
            files: [file],
        )

        // When
        try subject.write(snapshot: snapshot, to: outputPath)

        // Then
        let jsonString = try readJSONString(from: outputPath)

        #expect(jsonString == """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test.ipa",
            "sha256" : "abc123"
          },
          "files" : [
            {
              "path" : "app\\/file.txt",
              "sha256" : "hash1",
              "size" : 100
            }
          ],
          "version" : "0.1.0"
        }
        """)
    }

    @Test("Write snapshot with empty files array")
    func writeEmptyFiles() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date(timeIntervalSince1970: 1_234_567_890)
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
        let jsonString = try readJSONString(from: outputPath)

        let expectedJSON = """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test.ipa",
            "sha256" : "abc123"
          },
          "files" : [

          ],
          "version" : "0.1.0"
        }
        """

        #expect(jsonString == expectedJSON)
    }

    @Test("Write snapshot with different version numbers")
    func writeVersionNumbers() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date(timeIntervalSince1970: 1_234_567_890)
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: createdAt,
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
        let jsonString = try readJSONString(from: outputPath)

        let expectedJSON = """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test.ipa",
            "sha256" : "abc123"
          },
          "files" : [

          ],
          "version" : "1.2.3"
        }
        """

        #expect(jsonString == expectedJSON)
    }

    @Test("Write snapshot with special characters in paths")
    func writeSpecialCharactersInPaths() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date(timeIntervalSince1970: 1_234_567_890)
        let descriptor = Snapshot.Descriptor(
            filename: "test with spaces.ipa",
            createdAt: createdAt,
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
        let jsonString = try readJSONString(from: outputPath)

        let expectedJSON = """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test with spaces.ipa",
            "sha256" : "abc123"
          },
          "files" : [
            {
              "path" : "app\\/file with spaces.txt",
              "sha256" : "def456",
              "size" : 1024
            }
          ],
          "version" : "0.1.0"
        }
        """

        #expect(jsonString == expectedJSON)
    }

    @Test("Write snapshot with large file sizes")
    func writeLargeFileSizes() throws {
        // Given
        let subject = DefaultSnapshotParser(fileSystem: fileSystem)
        let tempDir = try fileSystem.makeTemporaryDirectory()
        defer { try? fileSystem.remove(at: tempDir.path) }

        let outputPath = tempDir.path.appending(component: "snapshot.json")
        let createdAt = Date(timeIntervalSince1970: 1_234_567_890)
        let descriptor = Snapshot.Descriptor(
            filename: "test.ipa",
            createdAt: createdAt,
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
        let jsonString = try readJSONString(from: outputPath)

        let expectedJSON = """
        {
          "descriptor" : {
            "createdAt" : 256260690,
            "filename" : "test.ipa",
            "sha256" : "abc123"
          },
          "files" : [
            {
              "path" : "app\\/large.bin",
              "sha256" : "def456",
              "size" : 10000000000
            }
          ],
          "version" : "0.1.0"
        }
        """

        #expect(jsonString == expectedJSON)
    }

    // MARK: - Private

    private func readJSONString(from path: AbsolutePath) throws -> String {
        let data = try fileSystem.read(from: path)
        guard let string = String(data: data, encoding: .utf8) else {
            throw CoreError.generic("Failed to convert data to UTF-8 string")
        }
        return string
    }
}
