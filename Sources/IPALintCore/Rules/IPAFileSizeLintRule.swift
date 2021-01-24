import Foundation
import TSCBasic

final class IPAFileSizeLintRule: FileLintRule, ConfigurableLintRule {
    var configuration = IPAFileSizeLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
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
        var violations: [LintRuleResult.Violation] = []
        let fileSize = try fileSystem.fileSize(at: ipaPath)
        if let maxSize = configuration.setting(\.maxSize), let value = maxSize.value, fileSize > value {
            violations.append(
                .init(severity: maxSize.severity,
                      message: "The .ipa package size is bigger than max_size"
                          + " -- max_size=\(value), ipa_size=\(fileSize)")
            )
        }
        if let minSize = configuration.setting(\.minSize), let value = minSize.value, fileSize < value {
            violations.append(
                .init(severity: minSize.severity,
                      message: "The .ipa package size is smaller than min_size"
                          + " -- min_size=\(value), ipa_size=\(fileSize)")
            )
        }
        return result(violations: violations)
    }
}

struct IPAFileSizeLintRuleConfiguration: LintRuleConfiguration {
    struct Settings: Codable {
        var minSize: FileSize?
        var maxSize: FileSize?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
