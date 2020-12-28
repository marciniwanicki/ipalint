//
//  Rule.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation
import TSCBasic

struct LintRuleResult {
    struct GenericViolation {
        let rule: LintRuleDescriptor
        let severity: ViolationSeverity
    }

    enum ViolationSeverity {
        case warning
        case error
    }

    enum Violation {
        case generic(GenericViolation)
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

protocol LintRuleConfiguration: LintRuleConfigurationModifier {
}

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
