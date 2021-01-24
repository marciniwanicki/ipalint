import Foundation

final class FileExtensionsLintRule: FileSystemTreeLintRule, ConfigurableLintRule {
    var configuration = FileExtensionsLintRuleConfiguration()
    let descriptor: LintRuleDescriptor = .init(
        identifier: .init(rawValue: "file_extensions"),
        name: "File extensions",
        description: """
        This is some description
        """
    )

    func lint(with fileSystemTree: FileSystemTree) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []
        let relativePaths = fileSystemTree.allFilesIterator().all().map {
            $0.relative(to: fileSystemTree.path)
        }

        if let expectOnly = configuration.setting(\.expectOnly), let value = expectOnly.value {
            relativePaths.forEach { path in
                if let fileExtension = path.extension, !value.contains(fileExtension) {
                    violations.append(
                        .init(severity: expectOnly.severity,
                              message: "The .ipa bundle contains a file with an unexpected estension"
                                  + " -- extension=\(fileExtension), path=\(path.pathString)")
                    )
                }
            }
        }
        if let forbidden = configuration.setting(\.forbidden), let value = forbidden.value {
            relativePaths.forEach { path in
                if let fileExtension = path.extension, value.contains(fileExtension) {
                    violations.append(
                        .init(severity: forbidden.severity,
                              message: "The .ipa bundle contains a file with forbidden extension"
                                  + " -- extension=\(fileExtension), path=\(path.pathString)")
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
