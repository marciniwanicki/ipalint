//
//  SnapshotCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

struct SnapshotCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "snapshot",
        abstract: "Creates a snapshot file of a given .ipa package."
    )

    func run() throws {
        try r.resolveSnapshotExecutor().execute(command: self)
    }

    final class Executor {
        private let interactor: SnapshotInteractor
        private let printer: Printer

        init(interactor: SnapshotInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: SnapshotCommand) throws {
            printer.error("SnapshotCommand command has not been implemented yet")
        }
    }
}
