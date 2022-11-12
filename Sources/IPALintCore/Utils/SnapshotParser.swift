import Foundation
import TSCBasic

protocol SnapshotParser {
    func write(snapshot: Snapshot, to path: AbsolutePath) throws
}

final class DefaultSnapshotParser: SnapshotParser {
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func write(snapshot: Snapshot, to path: AbsolutePath) throws {
        let codableSnapshot = snapshot.codable()
        let jsonData = try jsonEncoder.encode(codableSnapshot)
        try fileSystem.write(data: jsonData, to: path)
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
            sha256: descriptor.sha256
        )
        return SnapshotCodable(
            version: codableVersion,
            descriptor: codableDescriptor,
            files: codableFiles
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
