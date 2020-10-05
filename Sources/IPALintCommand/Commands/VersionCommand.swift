import Foundation
import ArgumentParser

struct VersionCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "version",
        abstract: "Show version.")

    func run() {
        printer.text(Constants.version.description)
    }

    // MARK: - Private

    private var printer: Printer { Resolver.shared.printer }
}
