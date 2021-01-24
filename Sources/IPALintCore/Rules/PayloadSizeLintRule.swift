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
        let directorySize = try fileSystem.directorySize(at: content.payloadPath)
        var violations: [LintRuleResult.Violation] = []

        if let maxSize = configuration.setting(\.maxSize), let value = maxSize.value, directorySize > value {
            violations.append(
                .init(severity: maxSize.severity,
                      message: "The payload directory size is bigger than max_size"
                          + " -- max_size=\(value), payload_size=\(directorySize)")
            )
        }
        if let minSize = configuration.setting(\.minSize), let value = minSize.value, directorySize < value {
            violations.append(
                .init(severity: minSize.severity,
                      message: "The payload directory size is smaller than min_size"
                          + " -- min_size=\(value), payload_size=\(directorySize)")
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
