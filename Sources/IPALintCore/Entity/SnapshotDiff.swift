//
//  File.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 27/12/2020.
//

import Foundation
import TSCBasic

public struct SnapshotDiff {
    enum FileDiff {
        case onlyInFirst(Snapshot.File)
        case onlyInSecond(Snapshot.File)
        case different(FileDiffDescriptor)
    }

    struct FileDiffDescriptor {
        let path: RelativePath
        let firstSha256: String
        let firstSize: FileSize
        let secondSha256: String
        let secondSize: FileSize
        let diffSize: FileSize
        let sizeReduced: Bool
    }

    let differences: [FileDiff]
}
