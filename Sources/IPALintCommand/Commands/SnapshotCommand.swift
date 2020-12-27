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

    @Option(
        name: .shortAndLong,
        help: "Path to .ipa file.",
        completion: .directory
    )
    var path: String?

    @Option(
        name: .shortAndLong,
        help: "Path to temp directory.",
        completion: .directory
    )
    var temp: String?

    @Option(
        name: .shortAndLong,
        help: "Path to the output file.",
        completion: .directory
    )
    var output: String?

    func run() throws {
        try r.resolveSnapshotExecutor().execute(command: self)
    }

    private func context() -> SnapshotContext {
        .init(ipaPath: path,
              tempPath: temp,
              outputPath: output)
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
            let result = try interactor.snapshot(with: command.context())
            print(result)
            printer.text("...")
        }
    }
}
