//
//  LintResultRenderer.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 28/12/2020.
//

import Foundation

public protocol LintResultRenderer {
    func render(result: LintResult, to output: Output)
}

public final class TextLintResultRenderer: LintResultRenderer {
    public init() {}

    public func render(result: LintResult, to output: Output) {
        result.ruleResults.forEach { result in
            if result.violations.isEmpty {
                output.write(.stdout, "[\(result.rule.name)] Passed.\n")
            } else {
                result.violations.forEach { violation in
                    switch violation {
                    case let .generic(violation):
                        output.write(.stdout, "\(violation.severity): \(violation.message) (\(result.rule.identifier.rawValue))\n")
                    }
                }
            }
        }
    }
}
