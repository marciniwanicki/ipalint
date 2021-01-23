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

        let errorMinSize = configuration.error.minSize ?? .min
        let errorMaxSize = configuration.error.maxSize ?? .max
        let warningMinSize = configuration.warning.minSize ?? .min
        let warningMaxSize = configuration.warning.maxSize ?? .max

        if fileSize < errorMinSize {
            violations.append(
                .warning(
                    message: "The .ipa package size is smaller than min_size"
                        + " -- min_size=\(errorMinSize), ipa_size=\(fileSize)"
                )
            )
        } else if fileSize < warningMinSize {
            violations.append(
                .error(
                    message: "The .ipa package size is smaller than min_size"
                        + " -- min_size=\(warningMinSize), ipa_size=\(fileSize)"
                )
            )
        }

        if fileSize > errorMaxSize {
            violations.append(
                .warning(
                    message: "The .ipa package size is bigger than max_size"
                        + " -- max_size=\(errorMaxSize), ipa_size=\(fileSize)"
                )
            )
        } else if fileSize > warningMaxSize {
            violations.append(
                .error(
                    message: "The .ipa package size is bigger than max_size"
                        + " -- max_size=\(warningMaxSize), ipa_size=\(fileSize)"
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
