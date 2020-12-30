import Foundation

public protocol LintResultRenderer {
    func render(result: LintResult)
}

public final class TextLintResultRenderer: LintResultRenderer {
    private let output: RichTextOutput

    public init(output: RichTextOutput) {
        self.output = output
    }

    public func render(result: LintResult) {
        result.ruleResults.forEach(renderLintRuleResult)
    }

    private func renderLintRuleResult(_ result: LintRuleResult) {
        guard !result.violations.isEmpty else {
            output.write(
                .text("[", .color(.darkGray))
                    + .text("OK", .color(.green))
                    + .text("]", .color(.darkGray))
                    + .text(" \(result.rule.identifier.rawValue)", .color(.lightGray))
                    + .text(" rule", .color(.darkGray))
                    + .newLine
            )
            return
        }
        result.violations.forEach { violation in
            renderViolation(violation, ruleIdentifier: result.rule.identifier.rawValue)
        }
    }

    private func renderViolation(_ violation: LintRuleResult.Violation, ruleIdentifier: String) {
        switch violation {
        case let .generic(violation):
            output.write(
                .text("[", .color(.darkGray))
                    + .text(violation.severity.rawValue.uppercased(), .color(color(from: violation.severity)))
                    + .text("]", .color(.darkGray))
                    + .text(" \(ruleIdentifier)", .color(.lightGray))
                    + .text(" rule:", .color(.darkGray))
                    + .text(" \(violation.message)", .color(color(from: violation.severity)))
                    + .newLine
            )
        }
    }

    private func color(from severity: LintRuleResult.ViolationSeverity) -> RichText.Color {
        switch severity {
        case .warning:
            return .yellow
        case .error:
            return .red
        }
    }
}

private extension Output {
    func write(violation: LintRuleResult.Violation, ruleIdentifier: String) {
        switch violation {
        case let .generic(violation):
            write("\(violation.severity.rawValue): \(violation.message) (\(ruleIdentifier))\n")
        }
    }
}
