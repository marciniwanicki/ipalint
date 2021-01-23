import Foundation
import TSCBasic

final class PayloadSizeLintRule: ContentLintRule, ConfigurableLintRule {
    var configuration = PayloadSizeLintRuleConfiguration()
    let descriptor: LintRuleDescriptor = .init(
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
        let directorySize = try fileSystem.directorySize(at: content.payloadPath)
        var violations: [LintRuleResult.Violation] = []

        let errorMinSize = configuration.error.minSize ?? .min
        let errorMaxSize = configuration.error.maxSize ?? .max
        let warningMinSize = configuration.warning.minSize ?? .min
        let warningMaxSize = configuration.warning.maxSize ?? .max

        if directorySize < errorMinSize {
            violations.append(
                .error(
                    message: "The payload directory size is smaller than min_size"
                        + " -- min_size=\(errorMinSize), payload_size=\(directorySize)"
                )
            )
        } else if directorySize < warningMinSize {
            violations.append(
                .warning(
                    message: "The payload directory size is smaller than min_size"
                        + " -- min_size=\(warningMinSize), payload_size=\(directorySize)"
                )
            )
        }

        if directorySize > errorMaxSize {
            violations.append(
                .error(
                    message: "The payload directory size is bigger than max_size"
                        + " -- max_size=\(errorMaxSize), payload_size=\(directorySize)"
                )
            )
        } else if directorySize > warningMaxSize {
            violations.append(
                .warning(
                    message: "The payload directory size is bigger than max_size"
                        + " -- max_size=\(warningMaxSize), payload_size=\(directorySize)"
                )
            )
        }

        return .init(rule: descriptor, violations: violations)
    }
}

struct PayloadSizeLintRuleConfiguration: LintRuleConfiguration {
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
