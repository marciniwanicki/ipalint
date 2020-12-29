import Foundation

public protocol LintResultRenderer {
    func render(result: LintResult, to output: Output)
}

public final class TextLintResultRenderer: LintResultRenderer {
    public init() {}

    public func render(result: LintResult, to output: Output) {
        result.ruleResults.forEach { result in
            if result.violations.isEmpty {
                output.write(.stdout, "✔ Passed '\(result.rule.identifier.rawValue)' rule\n")
                return
            }
            result.violations.forEach { violation in
                output.write(violation: violation, ruleIdentifier: result.rule.identifier.rawValue)
            }
        }
    }
}

private extension Output {
    func write(violation: LintRuleResult.Violation, ruleIdentifier: String) {
        switch violation {
        case let .generic(violation):
            write(.stdout, "\(violation.severity.rawValue): \(violation.message) (\(ruleIdentifier))\n")
        }
    }
}
