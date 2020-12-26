import ArgumentParser
import TSCBasic
import Foundation

public final class CommandRunner {
    public init() {}

    public func run(with arguments: [String]) -> Int32 {
        MainCommand.run(with: arguments)
    }
}

private struct MainCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "ipalint",
        subcommands: [
            VersionCommand.self,
            LintCommand.self,
            InfoCommand.self,
            DiffCommand.self
        ]
    )

    func run() throws {}

    static func run(with arguments: [String]? = nil) -> Int32 {
        do {
            var command = try parseAsRoot(arguments)
            try command.run()
            return 0
        } catch {
            return 1
        }
    }
}
