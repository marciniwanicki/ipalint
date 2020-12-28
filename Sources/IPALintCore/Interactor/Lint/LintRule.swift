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

protocol LintRuleConfiguration {
    mutating func apply(configuration: Any) throws
}

protocol LintRule {
    var descriptor: LintRuleDescriptor { get }
    var configuration: LintRuleConfiguration { get set }
}

protocol FileLintRule: LintRule {
    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult
}

protocol ContentLintRule: LintRule {
    func lint(with content: IPAContent) throws -> LintRuleResult
}

enum LintRuleType {
    case file(FileLintRule)
    case content(ContentLintRule)

    var identifier: LintRuleIdentifier {
        switch self {
        case let .file(rule):
            return rule.descriptor.identifier
        case let .content(rule):
            return rule.descriptor.identifier
        }
    }
}
