import Foundation
import TSCBasic
import TSCUtility

public struct Snapshot: Equatable {
    struct Descriptor: Equatable {
        let filename: String
        let createdAt: Date
        let sha256: String
    }

    enum Metadata: Equatable {}

    struct File: Equatable {
        let path: RelativePath
        let sha256: String
        let size: FileSize
        let metadata: [Metadata]
    }

    var version: Version = .init(0, 1, 0)
    var descriptor: Descriptor
    var files: [File]
}
