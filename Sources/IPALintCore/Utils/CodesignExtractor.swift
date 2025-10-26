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

protocol CodesignExtractor {
    func entitlements(at appPath: AbsolutePath) throws -> Entitlements
}

final class DefaultCodesignExtractor: CodesignExtractor {
    private let system: System

    init(system: System) {
        self.system = system
    }

    func entitlements(at appPath: AbsolutePath) throws -> Entitlements {
        let command = ["xcrun", "codesign", "-d", "--entitlements", ":-", appPath.pathString]
        let output = CaptureOutput()
        try CoreError.rethrowCommand(
            { try system.execute(command, output: .custom(output)) },
            command: command,
            message: "Cannot read the .ipa file entitlements, the following command failed."
        )
        let data = output.stdoutString.data(using: .utf8)!
        guard let dictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            throw CoreError.generic("Cannot read the codesign entitlements")
        }
        return Entitlements(dictionary: dictionary)
    }
}
