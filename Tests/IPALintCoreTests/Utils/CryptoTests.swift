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

@Suite("Crypto Tests")
struct CryptoTests {
    private let subject = DefaultCrypto()
    private let fileSystem = TSCBasic.localFileSystem

    @Test("SHA256 hash of empty file")
    func sha256EmptyFile() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile = tempDir.appending(component: "empty.txt")
        try fileSystem.writeFileContents(testFile, bytes: ByteString([]))

        // When
        let hash = try subject.sha256String(at: testFile)

        // Then
        // SHA256 of empty file is e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        #expect(hash == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }

    @Test("SHA256 hash of file with known content")
    func sha256KnownContent() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile = tempDir.appending(component: "hello.txt")
        try fileSystem.writeFileContents(testFile, bytes: ByteString("hello world\n".utf8))

        // When
        let hash = try subject.sha256String(at: testFile)

        // Then
        // SHA256 of "hello world\n" is a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447
        #expect(hash == "a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447")
    }

    @Test("SHA256 returns Data object")
    func sha256ReturnsData() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile = tempDir.appending(component: "test.txt")
        try fileSystem.writeFileContents(testFile, bytes: ByteString("test".utf8))

        // When
        let hashData = try subject.sha256(at: testFile)

        // Then
        #expect(hashData.count == 32) // SHA256 produces 32 bytes (256 bits)
    }

    @Test("SHA256 string format is lowercase hex")
    func sha256StringFormat() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile = tempDir.appending(component: "test.txt")
        try fileSystem.writeFileContents(testFile, bytes: ByteString("test".utf8))

        // When
        let hash = try subject.sha256String(at: testFile)

        // Then
        #expect(hash.count == 64) // 32 bytes * 2 hex chars = 64 characters
        #expect(hash.allSatisfy { $0.isHexDigit })
        #expect(hash == hash.lowercased()) // Verify lowercase
    }

    @Test("SHA256 of same content produces same hash")
    func sha256Consistency() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile1 = tempDir.appending(component: "file1.txt")
        let testFile2 = tempDir.appending(component: "file2.txt")
        let content = "identical content"
        try fileSystem.writeFileContents(testFile1, bytes: ByteString(content.utf8))
        try fileSystem.writeFileContents(testFile2, bytes: ByteString(content.utf8))

        // When
        let hash1 = try subject.sha256String(at: testFile1)
        let hash2 = try subject.sha256String(at: testFile2)

        // Then
        #expect(hash1 == hash2)
    }

    @Test("SHA256 of different content produces different hash")
    func sha256Different() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile1 = tempDir.appending(component: "file1.txt")
        let testFile2 = tempDir.appending(component: "file2.txt")
        try fileSystem.writeFileContents(testFile1, bytes: ByteString("content A".utf8))
        try fileSystem.writeFileContents(testFile2, bytes: ByteString("content B".utf8))

        // When
        let hash1 = try subject.sha256String(at: testFile1)
        let hash2 = try subject.sha256String(at: testFile2)

        // Then
        #expect(hash1 != hash2)
    }

    @Test("SHA256 handles large files")
    func sha256LargeFile() throws {
        // Given
        let tempDir = try fileSystem.tempDirectory.appending(component: UUID().uuidString)
        try fileSystem.createDirectory(tempDir, recursive: true)
        defer { try? fileSystem.removeFileTree(tempDir) }

        let testFile = tempDir.appending(component: "large.bin")
        // Create a file larger than the buffer size (4096 bytes) to test streaming
        let largeContent = Data(repeating: 0x42, count: 10000)
        try fileSystem.writeFileContents(testFile, bytes: ByteString(largeContent))

        // When
        let hash = try subject.sha256String(at: testFile)

        // Then
        #expect(hash.count == 64)
        #expect(!hash.isEmpty)
    }

    @Test("SHA256 throws error for non-existent file")
    func sha256NonExistentFile() throws {
        // Given
        let nonExistentPath = try AbsolutePath(validating: "/tmp/\(UUID().uuidString)/nonexistent.txt")

        // When/Then
        #expect(throws: Error.self) {
            _ = try subject.sha256(at: nonExistentPath)
        }
    }
}
