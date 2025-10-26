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
