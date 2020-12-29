import Foundation
import TSCBasic
import TSCUtility

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
