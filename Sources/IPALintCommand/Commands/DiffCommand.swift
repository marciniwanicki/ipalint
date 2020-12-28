//
//  DiffCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

struct DiffCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "diff",
        abstract: "Diffs two ipa packages."
    )

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory
    )
    var path1: String

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory
    )
    var path2: String

    // TODO
//    @Option(
//        name: .shortAndLong,
//        help: "Path to temp directory.",
//        completion: .directory
//    )
//    var temp: String?

    func run() throws {
        try r.resolveDiffExecutor().execute(command: self)
    }

    private func context() -> DiffContext {
        .init(path1: path1,
              path2: path2)
    }

    final class Executor {
        private let interactor: DiffInteractor
        private let printer: Printer

        init(interactor: DiffInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: DiffCommand) throws {
            let result = try interactor.diff(with: command.context())
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> DiffResultRenderer {
            TextDiffResultRenderer()
        }
    }
}
