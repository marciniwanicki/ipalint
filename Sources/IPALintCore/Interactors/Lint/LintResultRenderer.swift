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
                .text("✓", .color(.green))
                    + .text(" \(result.rule.identifier.rawValue)", .color(.darkGray))
                    + .newLine
            )
            return
        }
        result.violations.forEach { violation in
            renderViolation(violation, ruleIdentifier: result.rule.identifier.rawValue)
        }
    }

    private func renderViolation(_ violation: LintRuleResult.Violation, ruleIdentifier: String) {
        output.write(
            .text("\(violation.severity.rawValue.lowercased()):", .color(color(from: violation.severity)))
                + .text(" \(violation.message)", .color(color(from: violation.severity)))
                + .text(" (\(ruleIdentifier))", .color(.darkGray))
                + .newLine
        )
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
