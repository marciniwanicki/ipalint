import Foundation

final class FrameworksLintRule: ContentLintRule, ConfigurableLintRule {
    var configuration = FrameworksLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
        identifier: .init(rawValue: "frameworks"),
        name: "Frameworks",
        description: """
        This is some description
        """
    )

    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    // swiftlint:disable:next function_body_length
    func lint(with content: Content) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []

        // TODO: Fix linting ipa without any dynamic libraries
        let frameworksPath = content.appPath.appending(component: "Frameworks")
        let frameworks: Set<String> = try Set(fileSystem.list(at: frameworksPath).compactMap {
            switch $0 {
            case let .directory(frameworksPath):
                return String(frameworksPath.path.basename.dropLast(10)) // ".framework"
            case .file:
                return nil
            }
        })

        if let maxCount = configuration.setting(\.maxCount), let value = maxCount.value, frameworks.count > value {
            violations.append(
                .init(
                    severity: maxCount.severity,
                    message: "Too many dynamic frameworks"
                        + " -- min_count=\(value), frameworks_count=\(frameworks.count)"
                )
            )
        }
        if let minCount = configuration.setting(\.minCount), let value = minCount.value, frameworks.count < value {
            violations.append(
                .init(
                    severity: minCount.severity,
                    message: "Too few dynamic frameworks"
                        + " -- max_count=\(value), frameworks_count=\(frameworks.count)"
                )
            )
        }
        if let count = configuration.setting(\.count), let value = count.value, frameworks.count != value {
            violations.append(
                .init(
                    severity: count.severity,
                    message: "Unexpected number of dynamic frameworks"
                        + " -- count=\(value), frameworks_count=\(frameworks.count)"
                )
            )
        }

        // TODO: Improve the format of the message
        if let list = configuration.setting(\.list), let value = list.value, frameworks != value {
            let missing = value.subtracting(frameworks).sorted()
            let unexpected = frameworks.subtracting(value).sorted()
            violations.append(
                .init(
                    severity: list.severity,
                    message: "Unexpected dynamic framework(s)"
                        + " -- missing_frameworks=\(missing), unexpected_frameworks=\(unexpected)"
                )
            )
        }

        if let include = configuration.setting(\.include), let value = include.value,
           frameworks.isStrictSuperset(of: value) {
            let missing = value.subtracting(frameworks).sorted()
            violations.append(
                .init(
                    severity: include.severity,
                    message: "Missing dynamic framework(s)"
                        + " -- missing_frameworks=\(missing)"
                )
            )
        }

        if let exclude = configuration.setting(\.exclude),
           let value = exclude.value,
           !frameworks.isDisjoint(with: value) {
            let unexpected = frameworks.intersection(value)
            violations.append(
                .init(
                    severity: exclude.severity,
                    message: "Found unexpected dynamic framework(s)"
                        + " -- unexpected_frameworks=\(unexpected)"
                )
            )
        }

        return result(violations: violations)
    }
}

struct FrameworksLintRuleConfiguration: LintRuleConfiguration {
    struct Settings: Codable {
        var maxCount: UInt?
        var minCount: UInt?
        var count: UInt?
        var list: Set<String>?
        var include: Set<String>?
        var exclude: Set<String>?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
