import ArgumentParser
import Foundation

public final class CommandRunner {
    struct MainCommand: ParsableCommand {
        static let configuration: CommandConfiguration = .init(
            commandName: "ipalint",
            subcommands: [
                VersionCommand.self,
            ]
        )

        func run() throws {}
    }

    public static func run() {
        MainCommand.main()
    }
}
