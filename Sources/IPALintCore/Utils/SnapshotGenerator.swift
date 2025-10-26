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

protocol SnapshotGenerator {
    func snapshot(of content: Content) throws -> Snapshot
}

final class DefaultSnapshotGenerator: SnapshotGenerator {
    private let fileSystem: FileSystem
    private let crypto: Crypto

    init(
        fileSystem: FileSystem,
        crypto: Crypto
    ) {
        self.fileSystem = fileSystem
        self.crypto = crypto
    }

    func snapshot(of content: Content) throws -> Snapshot {
        let fileSystemTree = try fileSystem.tree(at: content.temporaryDirectory.path)
        let files = try fileSystemTree.allFilesIterator().all().reduce(into: [Snapshot.File]()) { acc, path in
            let relativePath = path.relative(to: content.temporaryDirectory.path)
            let sha256 = try crypto.sha256String(at: path)
            let fileSize = try fileSystem.fileSize(at: path)
            acc.append(.init(
                path: relativePath,
                sha256: sha256,
                size: fileSize
            ))
        }
        let ipaSha256 = try crypto.sha256String(at: content.ipaPath)
        let descriptor = Snapshot.Descriptor(
            filename: content.ipaPath.basename,
            createdAt: Date() /* FIXME: */,
            sha256: ipaSha256
        )
        return Snapshot(descriptor: descriptor, files: files)
    }
}
