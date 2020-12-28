//
//  DiffCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

struct DiffCommand: Command {
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

    func context() -> DiffContext {
        .init(path1: path1,
              path2: path2)
    }

    final class Executor: CommandExecutor {
        private let interactor: DiffInteractor
        private let printer: Printer

        init(interactor: DiffInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(with context: DiffContext) throws {
            let result = try interactor.diff(with: context)
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> DiffResultRenderer {
            TextDiffResultRenderer()
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(DiffInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
