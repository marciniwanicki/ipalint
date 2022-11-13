import ArgumentParser
import Foundation
import IPALintCore
import TSCBasic

struct InfoCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "info",
        abstract: "Show info about the ipa package."
    )

    @Option(
        name: .shortAndLong,
        help: Help.Option.bundlePath,
        completion: .directory
    )
    var path: String

    @Option(
        name: .shortAndLong,
        help: "Path to temp directory.",
        completion: .directory
    )
    var temp: String?

    @Option(
        name: .shortAndLong,
        help: "Format of the output.",
        completion: .list(["text"])
    )
    var format: String?

    @Flag(help: "Do not use colors in the output.")
    var noColors: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: InfoInteractor
        private let printer: Printer

        init(interactor: InfoInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: InfoCommand) throws {
            let context = InfoContext(
                inputPath: command.path,
                tempPath: command.temp
            )
            let result = try interactor.info(with: context)
            renderer(colorsEnabled: !command.noColors).render(result: result)
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> InfoResultRenderer {
            TextInfoResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(
                    interactor: r.resolve(InfoInteractor.self),
                    printer: r.resolve(Printer.self)
                )
            }
        }
    }
}
