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
        if let minSize = configuration.warning.minSize, directorySize < minSize {
            violations.append(
                .warning(
                    message: "The payload directory size is smaller than min_size"
                        + " -- min_size=\(minSize), payload_size=\(directorySize)"
                )
            )
        }
        if let maxSize = configuration.warning.maxSize, directorySize > maxSize {
            violations.append(
                .warning(
                    message: "The payload directory size is bigger than max_size"
                        + " -- max_size=\(maxSize), payload_size=\(directorySize)"
                )
            )
        }
        if let minSize = configuration.error.minSize, directorySize < minSize {
            violations.append(
                .error(
                    message: "The payload directory size is smaller than min_size"
                        + " -- min_size=\(minSize), payload_size=\(directorySize)"
                )
            )
        }
        if let maxSize = configuration.error.maxSize, directorySize > maxSize {
            violations.append(
                .error(
                    message: "The payload directory size is bigger than max_size"
                        + " -- max_size=\(maxSize), payload_size=\(directorySize)"
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
