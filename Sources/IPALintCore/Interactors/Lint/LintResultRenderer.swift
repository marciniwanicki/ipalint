//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
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
                    + .newLine,
            )
            return
        }
        for violation in result.violations {
            renderViolation(violation, ruleIdentifier: result.rule.identifier.rawValue)
        }
    }

    private func renderViolation(_ violation: LintRuleResult.Violation, ruleIdentifier: String) {
        output.write(
            .text("\(violation.severity.rawValue.capitalizingFirstLetter()):", .color(color(from: violation.severity)))
                + .text(" \(violation.message)", .color(color(from: violation.severity)))
                + .text(" (\(ruleIdentifier))", .color(.darkGray))
                + .newLine,
        )
    }

    private func color(from severity: LintRuleResult.ViolationSeverity) -> RichText.Color {
        switch severity {
        case .warning:
            .yellow
        case .error:
            .red
        }
    }
}
