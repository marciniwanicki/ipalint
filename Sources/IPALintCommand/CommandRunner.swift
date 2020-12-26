import ArgumentParser
import TSCBasic
import Foundation
import IPALintCore

public final class CommandRunner {
    public init() {}

    public func run(with arguments: [String]) -> Int32 {
        MainCommand.run(with: arguments)
    }
}

struct MainCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "ipalint",
        subcommands: [
            VersionCommand.self,
            LintCommand.self,
            InfoCommand.self,
            DiffCommand.self,
            SnapshotCommand.self
        ]
    )

    func run() throws {}

    static func run(with arguments: [String]? = nil) -> Int32 {
        return Resolver().resolveMainExecutor().execute(with: arguments ?? [])
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(with arguments: [String]) -> Int32 {
            do {
                var command = try parseAsRoot(arguments)
                try command.run()
                return 0
            } catch let error as CoreError {
                return handleCoreError(error)
            } catch {
                exit(withError: error)
            }
        }

        private func handleCoreError(_ error: CoreError) -> Int32 {
            switch error {
            case let .generic(message):
                printer.error(message)
                return 1
            }
        }
    }
}
