import Foundation

public struct LintContext {
    public let ipaPath: String?
    public let tempPath: String?
    public let configPath: String?

    public init(ipaPath: String?, tempPath: String?, configPath: String?) {
        self.ipaPath = ipaPath
        self.tempPath = tempPath
        self.configPath = configPath
    }
}

public struct LintResult {
    let ruleResults: [LintRuleResult]

    public var hasError: Bool {
        ruleResults.contains { ruleResult in
            ruleResult.violations.contains { violation in
                violation.severity == .error
            }
        }
    }

    public var hasWarning: Bool {
        ruleResults.contains { ruleResult in
            ruleResult.violations.contains { violation in
                violation.severity == .warning
            }
        }
    }
}

public protocol LintInteractor {
    func lint(with context: LintContext) throws -> LintResult
}

final class DefaultLintInteractor: LintInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let configurationLoader: ConfigurationLoader
    private let rules: [TypedLintRule]

    init(fileSystem: FileSystem,
         contentExtractor: ContentExtractor,
         configurationLoader: ConfigurationLoader,
         rules: [TypedLintRule]) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.configurationLoader = configurationLoader
        self.rules = rules
    }

    func lint(with context: LintContext) throws -> LintResult {
        let configurationPath = try context.configPath.map { try fileSystem.absolutePath(from: $0) } ?? fileSystem
            .currentWorkingDirectory.appending(component: ".ipalint.yml")
        let configuration = try configurationLoader.load(from: configurationPath)
        let rulesMap = rules.reduce(into: [LintRuleIdentifier: TypedLintRule]()) { acc, rule in
            acc[rule.descriptor.identifier] = rule
        }

        let typedLintRules: [TypedLintRule] = try configuration.all.rules.keys
            .sorted()
            .map { LintRuleIdentifier(rawValue: $0) }
            .compactMap { ruleIdentifier in
                guard let typedLintRule = rulesMap[ruleIdentifier] else {
                    throw CoreError
                        .generic("Unknown \(ruleIdentifier.rawValue.quoted()) rule found in the configuration")
                }
                return typedLintRule
            }

        try typedLintRules.forEach {
            try $0.apply(configuration: configuration.all.rules[$0.lintRule.descriptor.identifier.rawValue])
        }

        let enabledTypedLintRules = typedLintRules.filter { $0.isEnabled() }

        let content = try contentExtractor.content(from: context)
        let fileSystemTree = try fileSystem.tree(at: content.payloadPath)

        let results: [LintRuleResult] = try enabledTypedLintRules.map { typedLintRule in
            switch typedLintRule {
            case let .file(rule):
                return try rule.lint(with: content.ipaPath)
            case let .content(rule):
                return try rule.lint(with: content)
            case let .fileSystemTree(rule):
                return try rule.lint(wiht: fileSystemTree)
            }
        }
        return .init(ruleResults: results)
    }
}
