import Foundation
import IPALintCore

protocol Printer {
    func text(_ message: String)
    func error(_ message: String)
}

final class DefaultPrinter: Printer {
    private let output: Output

    init(output: Output) {
        self.output = output
    }

    func text(_ message: String) {
        output.write(.stdout, "\(message)\n")
    }

    func error(_ message: String) {
        output.write(.stdout, "ERROR: \(message)\n")
    }
}
