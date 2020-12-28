//
//  Linter.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

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

}

public protocol LintInteractor {
    func lint(with context: LintContext) throws -> LintResult
}

final class DefaultLintInteractor: LintInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let configurationLoader: ConfigurationLoader
    private let rules: [LintRuleType]

    init(fileSystem: FileSystem,
         contentExtractor: ContentExtractor,
         configurationLoader: ConfigurationLoader,
         rules: [LintRuleType]) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.configurationLoader = configurationLoader
        self.rules = rules
    }

    func lint(with context: LintContext) throws -> LintResult {
        // read configuration
        let configurationPath = try context.configPath.map { try fileSystem.absolutePath(from: $0) } ?? fileSystem.currentWorkingDirectory.appending(component: ".applint.yml")
        let configuration = try configurationLoader.load(from: configurationPath)
        let content = try contentExtractor.content(from: context)

        let rulesMap = rules.reduce(into: [LintRuleIdentifier: LintRuleType]()) { acc, rule in
            acc[rule.descriptor.identifier] = rule
        }

        try configuration.all.rules.keys
            .sorted()
            .map { LintRuleIdentifier(rawValue: $0) }
            .forEach { ruleIdentifier in
                guard let ruleType = rulesMap[ruleIdentifier] else {
                    print("UNKNOWN RULE")
                    return
                }
                let configuration = configuration.all.rules[ruleIdentifier.rawValue]!
                switch ruleType {
                case let .file(rule):
                    if var configurableRule = rule as? LintRuleConfigurationModifier {
                        try configurableRule.apply(configuration: configuration)
                    }
                    let result = try rule.lint(with: content.ipaPath)
                    print(result)
                case let .content(rule):
                    if var configurableRule = rule as? LintRuleConfigurationModifier {
                        try configurableRule.apply(configuration: configuration)
                    }
                    let result = try rule.lint(with: content)
                    print(result)
                }
        }

        // check if the file exists...


        // unpack ipa

        return LintResult()
    }

    // MARK: - Private
}
