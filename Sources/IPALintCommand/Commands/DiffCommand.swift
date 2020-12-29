import ArgumentParser
import Foundation
import IPALintCore

struct DiffCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "diff",
        abstract: "Diffs two ipa packages."
    )

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory
    )
    var path1: String

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory
    )
    var path2: String

    final class Executor: CommandExecutor {
        private let interactor: DiffInteractor
        private let printer: Printer

        init(interactor: DiffInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: DiffCommand) throws {
            let context = DiffContext(path1: command.path1, path2: command.path2)
            let result = try interactor.diff(with: context)
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> DiffResultRenderer {
            TextDiffResultRenderer()
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(DiffInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
