//
//  SnapshotCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser

struct SnapshotCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "snapshot",
        abstract: "Creates a snapshot file of a given .ipa package."
    )

    func run() throws {
        try Executor(printer: r.printer).execute(command: self)
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: SnapshotCommand) throws {
            printer.error("SnapshotCommand command has not been implemented yet")
        }
    }
}
