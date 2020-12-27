//
//  SnapshotInteractor.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
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

}

public struct Snapshot {
    struct Descriptor {
        let filename: String
        let createdAt: Date
        let sha256: String
    }

    struct File {
        let path: RelativePath
        let sha256: String
        let size: FileSize
    }

    var version: Version = .init(0, 1, 0)
    var descriptor: Descriptor
    var files: [File]
}

public protocol SnapshotInteractor {
    func snapshot(with context: SnapshotContext) throws -> SnapshotResult
}

final class DefaultSnapshotInteractor: SnapshotInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let crypto: Crypto

    init(fileSystem: FileSystem,
         contentExtractor: ContentExtractor,
         crypto: Crypto) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.crypto = crypto
    }

    func snapshot(with context: SnapshotContext) throws -> SnapshotResult {
        let content = try contentExtractor.content(from: context)
        let fileSystemTree = try fileSystem.tree(at: content.temporaryDirectory.path)
        let outputPath = try fileSystem.absolutePath(from: context.outputPath ?? "\(content.ipaPath.basenameWithoutExt)-snapshot.json")
        let files = try fileSystemTree.allFilesIterator().all().reduce(into: [Snapshot.File]()) { acc, path in
            let relativePath = path.relative(to: content.temporaryDirectory.path)
            let sha256 = try crypto.sha256String(at: path)
            let fileSize = try fileSystem.fileSize(at: path)
            acc.append(.init(path: relativePath,
                             sha256: sha256,
                             size: fileSize))
        }
        let ipaSha256 = try crypto.sha256String(at: content.ipaPath)
        let descriptor = Snapshot.Descriptor(filename: content.ipaPath.basename,
                                             createdAt: Date() /* FIXME */,
                                             sha256: ipaSha256)
        let snapshot = Snapshot(descriptor: descriptor, files: files)
        let codableSnapshot = snapshot.codable()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(codableSnapshot)

        try fileSystem.write(data: jsonData, to: outputPath)

        return .init()
    }
}

private extension Snapshot {
    func codable() -> SnapshotCodable {
        let codableVersion = version.description
        let codableFiles: [SnapshotCodable.File] = files.map { file in
            .init(path: file.path.pathString, sha256: file.sha256, size: file.size.bytes)
        }
        let codableDescriptor = SnapshotCodable.Descriptor(filename: descriptor.filename,
                                                           createdAt: descriptor.createdAt,
                                                           sha256: descriptor.sha256)
        return SnapshotCodable(version: codableVersion,
                               descriptor: codableDescriptor,
                               files: codableFiles)
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
