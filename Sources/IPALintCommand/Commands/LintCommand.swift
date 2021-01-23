import ArgumentParser
import Foundation
import IPALintCore

struct LintCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "lint",
        abstract: "Lints given ipa package."
    )

    @Option(
        name: .shortAndLong,
        help: "Path to .ipa file.",
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
        help: "Path to config file.",
        completion: .directory
    )
    var config: String?

    @Flag
    var noColors: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: LintInteractor
        private let printer: Printer

        init(interactor: LintInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: LintCommand) throws {
            let context = LintContext(ipaPath: command.path,
                                      tempPath: command.temp,
                                      configPath: command.config)
            let result = try interactor.lint(with: context)
            renderer(colorsEnabled: !command.noColors).render(result: result)
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> LintResultRenderer {
            TextLintResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(LintInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
