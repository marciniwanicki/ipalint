import Foundation
import IPALintCore

protocol Printer {
    var output: Output { get }

    func text(_ message: String)
    func error(_ message: String)
}

final class DefaultPrinter: Printer {
    let output: Output

    init(output: Output) {
        self.output = output
    }

    func text(_ message: String) {
        output.write("\(message)\n", to: .stdout)
    }

    func error(_ message: String) {
        output.write("Error: \(message)\n", to: .stderr)
    }
}

extension Printer {
    func richTextOutput(colorsEnabled: Bool = true) -> RichTextOutput {
        TerminalRichTextOutput(output: output, colorsEnabled: colorsEnabled)
    }
}
