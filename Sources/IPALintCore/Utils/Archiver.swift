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

protocol Archiver {
    func extract(
        source sourcePath: AbsolutePath,
        destination destinationPath: AbsolutePath
    ) throws
}

final class TarArchiver: Archiver {
    private let system: System

    init(system: System) {
        self.system = system
    }

    func extract(
        source sourcePath: AbsolutePath,
        destination destinationPath: AbsolutePath
    ) throws {
        let command = [
            "tar",
            "xvzf",
            sourcePath.pathString,
            "-C",
            destinationPath.pathString,
        ]

        try CoreError.rethrowCommand(
            { try system.execute(command, output: .muted) },
            command: command,
            message: "Cannot extract the .ipa file."
        )
    }
}
