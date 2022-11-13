import Foundation

final class EntitlementsLintRule: ContentLintRule, ConfigurableLintRule {
    var configuration = EntitlementsLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
        identifier: .init(rawValue: "entitlements"),
        name: "Entitlements",
        description: """
        This is some description
        """
    )

    private let codesignExtractor: CodesignExtractor

    init(codesignExtractor: CodesignExtractor) {
        self.codesignExtractor = codesignExtractor
    }

    func lint(with content: Content) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []
        let entitlements = try codesignExtractor.entitlements(at: content.appPath)
        guard let entitlements else {
            throw CoreError.generic("Cannot read the entitlements -- PATH=\(content.appPath)")
        }
        if let content = configuration.setting(\.content), let values = content.value {
            values.forEach { key, value in
                let presentValue = entitlements.properties[key]
                if presentValue != value {
                    violations.append(
                        .init(
                            severity: content.severity,
                            message: "Invalid entitlements property value"
                                + " -- property=\(key),"
                                + " expected_value=\(value),"
                                + " present_value=\(String(describing: presentValue))"
                        )
                    )
                }
            }
        }
        return result(violations: violations)
    }
}

struct EntitlementsLintRuleConfiguration: LintRuleConfiguration {
    struct Settings: Codable {
        var content: [String: Property]?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
