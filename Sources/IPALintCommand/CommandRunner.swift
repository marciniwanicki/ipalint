import ArgumentParser
import Foundation
import IPALintCore
import TSCBasic

public final class CommandRunner {
    public init() {}

    public func run(with arguments: [String]) -> Int32 {
        MainCommand.run(with: arguments)
    }
}

private struct MainCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "ipalint",
        subcommands: MainCommand.allSubcommands
    )

    func run() throws {
        _ = MainCommand.run(with: ["--help"])
    }

    static func run(with arguments: [String]? = nil) -> Int32 {
        Assembler(container: DefaultContainer())
            .assemble([CommonAssembly()])
            .assemble([Assembly()])
            .resolver()
            .resolve(Executor.self)
            .execute(with: arguments ?? [])
    }

    final class Executor {
        private let printer: Printer
        private let errorHandler: ErrorHandler

        init(printer: Printer, errorHandler: ErrorHandler) {
            self.printer = printer
            self.errorHandler = errorHandler
        }

        func printHelp() {
            printer.text(helpMessage())
        }

        func execute(with arguments: [String]) -> Int32 {
            do {
                var command = try parseAsRoot(arguments)
                try command.run()
                return 0
            } catch {
                return errorHandler.handle(error: error)
            }
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(printer: r.resolve(Printer.self),
                         errorHandler: r.resolve(ErrorHandler.self))
            }
            registry.register(ErrorHandler.self) { r in
                ErrorHandler(printer: r.resolve(Printer.self))
            }
        }
    }
}

private final class ErrorHandler {
    private let printer: Printer

    init(printer: Printer) {
        self.printer = printer
    }

    func handle(error: Error) -> Int32 {
        if let error = error as? CoreError {
            return handleCoreError(error)
        }
        return handleError(error)
    }

    // MARK: - Private

    private func handleCoreError(_ error: CoreError) -> Int32 {
        switch error {
        case let .generic(message):
            printer.error(message)
            return 1
        }
    }

    private func handleError(_ error: Error) -> Int32 {
        printer.text(MainCommand.fullMessage(for: error))
        return MainCommand.exitCode(for: error).rawValue
    }
}
