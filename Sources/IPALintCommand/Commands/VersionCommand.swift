import ArgumentParser
import Foundation

struct VersionCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "version",
        abstract: "Show version."
    )

    func run() throws {
        try Executor(printer: r.printer).execute(command: self)
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: VersionCommand) throws {
            printer.text(Constants.version.description)
        }
    }
}
