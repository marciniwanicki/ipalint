//
//  TestMeCommand.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import ArgumentParser
import Foundation
import IPALintCore
import TSCBasic

struct InfoCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "info",
        abstract: "Shows info about the ipa package."
    )

    @Option(
        name: .shortAndLong,
        help: "The path to .ipa file.",
        completion: .directory
    )
    var path: String?

    func run() throws {
        try r.resolveInfoExecutor().execute(command: self)
    }

    final class Executor {
        private let infoInteractor: InfoInteractor
        private let printer: Printer

        init(infoInteractor: InfoInteractor, printer: Printer) {
            self.infoInteractor = infoInteractor
            self.printer = printer
        }

        func execute(command: InfoCommand) throws {
            let context = InfoContext(path: command.path)
            let result = try infoInteractor.info(with: context)
            printer.result(result)
        }
    }
}

private extension Printer {
    func result(_ result: InfoResult) {
        result.properties.forEach {
            text($0.description)
        }
    }
}
