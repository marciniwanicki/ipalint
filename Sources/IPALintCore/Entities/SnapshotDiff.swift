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
