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
        output.write(.stdout, "\(message)\n")
    }

    func error(_ message: String) {
        output.write(.stdout, "ERROR: \(message)\n")
    }
}
