import ArgumentParser
import Foundation
import IPALintCore
import TSCUtility

struct VersionCommand: Command {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Show version."
    )

    final class Executor: CommandExecutor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: VersionCommand) throws {
            printer.text(Constants.version.description)
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(printer: r.resolve(Printer.self))
            }
        }
    }
}
