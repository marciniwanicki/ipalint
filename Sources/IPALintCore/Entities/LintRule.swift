import Foundation
import TSCBasic

struct LintRuleResult {
    enum ViolationSeverity: String {
        case warning
        case error
    }

    struct Violation {
        let severity: ViolationSeverity
        let message: String

        static func warning(message: String) -> Violation {
            return .init(severity: .warning, message: message)
        }

        static func error(message: String) -> Violation {
            return .init(severity: .error, message: message)
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

protocol FileSystemTreeLintRule: LintRule {
    func lint(wiht fileSystemTree: FileSystemTree) throws -> LintRuleResult
}

enum TypedLintRule {
    case file(FileLintRule)
    case content(ContentLintRule)
    case fileSystemTree(FileSystemTreeLintRule)

    var lintRule: LintRule {
        switch self {
        case let .file(rule):
            return rule
        case let .content(rule):
            return rule
        case let .fileSystemTree(rule):
            return rule
        }
    }

    var descriptor: LintRuleDescriptor {
        lintRule.descriptor
    }

    func isEnabled() -> Bool {
        if let configurableRule = lintRule as? LintRuleConfigurationModifier {
            return configurableRule.isEnabled()
        }
        return true
    }

    func apply(configuration: Any?) throws {
        guard let configuration = configuration else {
            return
        }
        if var configurableRule = lintRule as? LintRuleConfigurationModifier {
            try configurableRule.apply(configuration: configuration)
        }
    }
}
