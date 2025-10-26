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

final class FileExtensionsLintRule: FileSystemTreeLintRule, ConfigurableLintRule {
    var configuration = FileExtensionsLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
        identifier: .init(rawValue: "file_extensions"),
        name: "File extensions",
        description: """
        This is some description
        """,
    )

    func lint(with fileSystemTree: FileSystemTree) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []
        let relativePaths = fileSystemTree.allFilesIterator().all().map {
            $0.relative(to: fileSystemTree.path)
        }

        if let expectOnly = configuration.setting(\.expectOnly), let value = expectOnly.value {
            for path in relativePaths {
                if let fileExtension = path.extension, !value.contains(fileExtension) {
                    violations.append(
                        .init(
                            severity: expectOnly.severity,
                            message: "The .ipa bundle contains a file with an unexpected estension"
                                + " -- extension=\(fileExtension), path=\(path.pathString)",
                        ),
                    )
                }
            }
        }
        if let forbidden = configuration.setting(\.forbidden), let value = forbidden.value {
            for path in relativePaths {
                if let fileExtension = path.extension, value.contains(fileExtension) {
                    violations.append(
                        .init(
                            severity: forbidden.severity,
                            message: "The .ipa bundle contains a file with forbidden extension"
                                + " -- extension=\(fileExtension), path=\(path.pathString)",
                        ),
                    )
                }
            }
        }
        return result(violations: violations)
    }
}

struct FileExtensionsLintRuleConfiguration: LintRuleConfiguration {
    struct Settings: Codable {
        var expectOnly: Set<String>?
        var forbidden: Set<String>?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
