import ArgumentParser
import Foundation
import IPALintCore

struct SnapshotCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "snapshot",
        abstract: "Create a snapshot file of a given .ipa package."
    )

    @Option(
        name: .shortAndLong,
        help: "Path to .ipa file.",
        completion: .directory
    )
    var path: String?

    @Option(
        name: .shortAndLong,
        help: "Path to temp directory.",
        completion: .directory
    )
    var temp: String?

    @Option(
        name: .shortAndLong,
        help: "Path to the output file.",
        completion: .directory
    )
    var output: String?

    final class Executor: CommandExecutor {
        private let interactor: SnapshotInteractor
        private let printer: Printer

        init(interactor: SnapshotInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: SnapshotCommand) throws {
            let context = SnapshotContext(ipaPath: command.path,
                                          tempPath: command.temp,
                                          outputPath: command.output)
            let result = try interactor.snapshot(with: context)
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> SnapshotResultRenderer {
            TextSnapshotResultRenderer()
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(SnapshotInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
