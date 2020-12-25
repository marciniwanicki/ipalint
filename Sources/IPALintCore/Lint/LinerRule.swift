//
//  Rule.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

struct LinterRuleResult {

}

protocol LinterRule {
    func lint(with context: LinterContext) throws -> LinterRuleResult
}
