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

protocol HasIPAPath {
    var ipaPath: String? { get }
}

protocol HasTempPath {
    var tempPath: String? { get }
}

extension InfoContext: HasIPAPath, HasTempPath {}
extension SnapshotContext: HasIPAPath, HasTempPath {}
extension LintContext: HasIPAPath, HasTempPath {}

extension FileSystem {
    func ipaFilePath(from context: HasIPAPath) throws -> AbsolutePath {
        if let ipaPath = context.ipaPath {
            return try absolutePath(from: ipaPath)
        }

        let items: [AbsolutePath] = try list(at: currentWorkingDirectory)
            .compactMap {
                if case let .file(file) = $0, file.path.extension == "ipa" {
                    return currentWorkingDirectory.appending(file.path)
                }
                return nil
            }

        guard !items.isEmpty else {
            throw CoreError.generic("Did find any .ipa files in the current directory.")
        }
        guard items.count == 1 else {
            throw CoreError.generic("Found more than one (\(items.count)) in the current directory.")
        }
        return items[0]
    }

    func tempDirectoryPath(from context: HasTempPath) throws -> AbsolutePath? {
        if let path = context.tempPath {
            return try absolutePath(from: path)
        }
        return nil
    }
}
