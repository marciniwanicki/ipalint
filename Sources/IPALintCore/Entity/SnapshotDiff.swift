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
        case difference(FileDiffDescriptor)
    }

    struct FileDiffDescriptor {
        let path: RelativePath
        let firstSha256: String
        let firstSize: FileSize
        let secondSha256: String
        let secondSize: FileSize

        var deltaFileSize: DeltaFileSize {
            firstSize.delta(secondSize)
        }
    }

    let differences: [FileDiff]
}
