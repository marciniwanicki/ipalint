//
//  LintCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser

struct LintCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "lint",
        abstract: "Lints given ipa package."
    )

    func run() throws {
        try Executor(printer: r.printer).execute(command: self)
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: LintCommand) throws {
            printer.error("Lint command has not been implemented yet")
        }
    }
}
