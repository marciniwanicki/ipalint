//
//  Rule.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

struct LintRuleResult {

}

protocol LintRule {
    func lint(with context: LintContext) throws -> LintRuleResult
}
