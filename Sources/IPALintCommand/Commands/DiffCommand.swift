//
//  DiffCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser

struct DiffCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "diff",
        abstract: "Diffs two ipa packages."
    )

    func run() throws {
        try Executor(printer: r.printer).execute(command: self)
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: DiffCommand) throws {
            printer.error("Diff command has not been implemented yet")
        }
    }
}
