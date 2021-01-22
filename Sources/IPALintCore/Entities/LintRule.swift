import Foundation
import TSCBasic

struct LintRuleResult {
    struct GenericViolation {
        let severity: ViolationSeverity
        let message: String
    }

    enum ViolationSeverity: String {
        case warning
        case error
    }

    enum Violation {
        case generic(GenericViolation)

        static func warning(message: String) -> Violation {
            return .generic(.init(severity: .warning, message: message))
        }

        static func error(message: String) -> Violation {
            return .generic(.init(severity: .error, message: message))
        }
    }

    let rule: LintRuleDescriptor
    let violations: [Violation]
}

struct LintRuleIdentifier: RawRepresentable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

struct LintRuleDescriptor: Equatable {
    let identifier: LintRuleIdentifier
    let name: String
    let description: String
}

protocol LintRuleConfigurationModifier {
    func isEnabled() -> Bool

    mutating func apply(configuration: Any) throws
}

protocol LintRuleConfiguration: Codable {
    var enabled: Bool? { get set }
}

extension LintRuleConfiguration {
    func isEnabled() -> Bool {
        enabled ?? true
    }
}

protocol LintRule {
    var descriptor: LintRuleDescriptor { get }
}

protocol ConfigurableLintRule: LintRuleConfigurationModifier {
    associatedtype Configuration: LintRuleConfiguration

    var configuration: Configuration { get set }
}

extension ConfigurableLintRule {
    func isEnabled() -> Bool {
        configuration.isEnabled()
    }
}

extension LintRule where Self: ConfigurableLintRule {
    mutating func apply(configuration: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: configuration, options: .fragmentsAllowed)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.configuration = try decoder.decode(Configuration.self, from: data)
    }
}

protocol FileLintRule: LintRule {
    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult
}

protocol ContentLintRule: LintRule {
    func lint(with content: Content) throws -> LintRuleResult
}

enum LintRuleType {
    case file(FileLintRule)
    case content(ContentLintRule)

    var descriptor: LintRuleDescriptor {
        switch self {
        case let .file(rule):
            return rule.descriptor
        case let .content(rule):
            return rule.descriptor
        }
    }
}
