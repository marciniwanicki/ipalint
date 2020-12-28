//
//  SnapshotGenerator.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 27/12/2020.
//

import Foundation

protocol SnapshotGenerator {
    func snapshot(of content: Content) throws -> Snapshot
}

final class DefaultSnapshotGenerator: SnapshotGenerator {
    private let fileSystem: FileSystem
    private let crypto: Crypto

    init(fileSystem: FileSystem,
         crypto: Crypto) {
        self.fileSystem = fileSystem
        self.crypto = crypto
    }

    func snapshot(of content: Content) throws -> Snapshot {
        let fileSystemTree = try fileSystem.tree(at: content.temporaryDirectory.path)
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
                                             createdAt: Date() /* FIXME: */,
                                             sha256: ipaSha256)
        return Snapshot(descriptor: descriptor, files: files)
    }
}
