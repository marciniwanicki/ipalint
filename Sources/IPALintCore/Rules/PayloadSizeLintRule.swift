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

final class PayloadSizeLintRule: ContentLintRule, ConfigurableLintRule {
    var configuration = PayloadSizeLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
        identifier: .init(rawValue: "payload_size"),
        name: "Payload directory size",
        description: """
        This is some description
        """
    )

    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func lint(with content: Content) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []
        let directorySize = try fileSystem.directorySize(at: content.payloadPath)
        if let maxSize = configuration.setting(\.maxSize), let value = maxSize.value, directorySize > value {
            violations.append(
                .init(
                    severity: maxSize.severity,
                    message: "The payload directory size is bigger than max_size"
                        + " -- max_size=\(value), payload_size=\(directorySize)"
                )
            )
        }
        if let minSize = configuration.setting(\.minSize), let value = minSize.value, directorySize < value {
            violations.append(
                .init(
                    severity: minSize.severity,
                    message: "The payload directory size is smaller than min_size"
                        + " -- min_size=\(value), payload_size=\(directorySize)"
                )
            )
        }
        return result(violations: violations)
    }
}

struct PayloadSizeLintRuleConfiguration: LintRuleConfiguration {
    struct Settings: Codable {
        var minSize: FileSize?
        var maxSize: FileSize?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
