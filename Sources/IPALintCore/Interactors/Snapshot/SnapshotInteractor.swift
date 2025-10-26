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
import TSCBasic
import TSCUtility

public struct SnapshotContext {
    public let ipaPath: String?
    public let tempPath: String?
    public let outputPath: String?

    public init(ipaPath: String?, tempPath: String?, outputPath: String?) {
        self.ipaPath = ipaPath
        self.tempPath = tempPath
        self.outputPath = outputPath
    }
}

public struct SnapshotResult {
    public let snapshotPath: AbsolutePath
}

public protocol SnapshotInteractor {
    func snapshot(with context: SnapshotContext) throws -> SnapshotResult
}

final class DefaultSnapshotInteractor: SnapshotInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let snapshotGenerator: SnapshotGenerator
    private let snapshotParser: SnapshotParser

    init(
        fileSystem: FileSystem,
        contentExtractor: ContentExtractor,
        snapshotGenerator: SnapshotGenerator,
        snapshotParser: SnapshotParser,
    ) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.snapshotGenerator = snapshotGenerator
        self.snapshotParser = snapshotParser
    }

    func snapshot(with context: SnapshotContext) throws -> SnapshotResult {
        let content = try contentExtractor.content(from: context)
        let snapshot = try snapshotGenerator.snapshot(of: content)
        let outputPath = try fileSystem
            .absolutePath(from: context.outputPath ?? "\(content.ipaPath.basenameWithoutExt)-snapshot.json")

        try snapshotParser.write(snapshot: snapshot, to: outputPath)

        return .init(snapshotPath: outputPath)
    }
}

private extension Snapshot {
    func codable() -> SnapshotCodable {
        let codableVersion = version.description
        let codableFiles: [SnapshotCodable.File] = files.map { file in
            .init(path: file.path.pathString, sha256: file.sha256, size: file.size.bytes)
        }
        let codableDescriptor = SnapshotCodable.Descriptor(
            filename: descriptor.filename,
            createdAt: descriptor.createdAt,
            sha256: descriptor.sha256,
        )
        return SnapshotCodable(
            version: codableVersion,
            descriptor: codableDescriptor,
            files: codableFiles,
        )
    }
}

private struct SnapshotCodable: Codable {
    struct Descriptor: Codable {
        let filename: String
        let createdAt: Date
        let sha256: String
    }

    struct File: Codable {
        let path: String
        let sha256: String
        let size: UInt64
    }

    var version: String
    var descriptor: Descriptor
    var files: [File]
}
