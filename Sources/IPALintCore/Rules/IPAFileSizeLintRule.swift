import Foundation
import TSCBasic

final class IPAFileSizeLintRule: FileLintRule, ConfigurableLintRule {
    var configuration = IPAFileSizeLintRuleConfiguration()
    let descriptor: LintRuleDescriptor = .init(
        identifier: .init(rawValue: "ipa_file_size"),
        name: "Package size",
        description: """
        This is some description
        """
    )

    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult {
        let fileSize = try fileSystem.fileSize(at: ipaPath)
        var violations: [LintRuleResult.Violation] = []
        if let minSize = configuration.warning.minSize, fileSize < minSize {
            violations.append(
                .warning(
                    message: "The .ipa package size is smaller than min_size"
                        + " -- min_size=\(minSize), ipa_size=\(fileSize)"
                )
            )
        }
        if let maxSize = configuration.warning.maxSize, fileSize > maxSize {
            violations.append(
                .warning(
                    message: "The .ipa package size is bigger than max_size"
                        + " -- max_size=\(maxSize), ipa_size=\(fileSize)"
                )
            )
        }
        if let minSize = configuration.error.minSize, fileSize < minSize {
            violations.append(
                .error(
                    message: "The .ipa package size is smaller than min_size"
                        + " -- min_size=\(minSize), ipa_size=\(fileSize)"
                )
            )
        }
        if let maxSize = configuration.error.maxSize, fileSize > maxSize {
            violations.append(
                .error(
                    message: "The .ipa package size is bigger than max_size"
                        + " -- max_size=\(maxSize), ipa_size=\(fileSize)"
                )
            )
        }
        return .init(rule: descriptor, violations: violations)
    }
}

struct IPAFileSizeLintRuleConfiguration: LintRuleConfiguration {
    struct Warning: Codable {
        var minSize: FileSize?
        var maxSize: FileSize?
    }

    struct Error: Codable {
        var minSize: FileSize?
        var maxSize: FileSize?
    }

    var enabled: Bool?
    var warning = Warning()
    var error = Error()
}
