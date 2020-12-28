import Foundation
import TSCBasic

struct LintRuleResult {
    let rule: LintRuleDescriptor

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
    mutating func apply(configuration: Any) throws
}

protocol LintRuleConfiguration: LintRuleConfigurationModifier {}

protocol LintRule {
    var descriptor: LintRuleDescriptor { get }
}

protocol ConfigurableLintRule: LintRuleConfigurationModifier {
    associatedtype C: LintRuleConfiguration

    var configuration: C { get set }
}

extension LintRule where Self: ConfigurableLintRule {
    mutating func apply(configuration: Any) throws {
        try self.configuration.apply(configuration: configuration)
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
