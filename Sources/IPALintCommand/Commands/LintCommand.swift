//
//  LintCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

struct LintCommand: ParsableCommand {
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

    func run() throws {
        try r.resolveLintExecutor().execute(command: self)
    }

    private func context() -> LintContext {
        .init(ipaPath: path, tempPath: temp, configPath: config)
    }

    final class Executor {
        private let interactor: LintInteractor
        private let printer: Printer

        init(interactor: LintInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: LintCommand) throws {
            let result = try interactor.lint(with: command.context())
            print(result)
        }
    }
}
