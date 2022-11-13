import ArgumentParser
import Foundation
import IPALintCore

struct DiffCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "diff",
        abstract: "Diff two ipa packages."
    )

    @Option(
        name: .long,
        help: Help.Option.bundlePath1,
        completion: .directory
    )
    var path1: String

    @Option(
        name: .long,
        help: Help.Option.bundlePath2,
        completion: .directory
    )
    var path2: String

    @Flag
    var noColors: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: DiffInteractor
        private let printer: Printer

        init(
            interactor: DiffInteractor,
            printer: Printer
        ) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: DiffCommand) throws {
            let context = DiffContext(path1: command.path1, path2: command.path2)
            let result = try interactor.diff(with: context)
            renderer(colorsEnabled: !command.noColors).render(result: result)
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> DiffResultRenderer {
            TextDiffResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(
                    interactor: r.resolve(DiffInteractor.self),
                    printer: r.resolve(Printer.self)
                )
            }
        }
    }
}
