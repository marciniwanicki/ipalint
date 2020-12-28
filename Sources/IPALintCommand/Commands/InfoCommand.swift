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

struct InfoCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "info",
        abstract: "Shows info about the ipa package."
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
        help: "Format of the output.",
        completion: .list(["text"])
    )
    var format: String?

    func context() -> InfoContext {
        .init(ipaPath: path,
              tempPath: temp)
    }

    final class Executor: CommandExecutor {
        private let interactor: InfoInteractor
        private let printer: Printer

        init(interactor: InfoInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(with context: InfoContext) throws {
            let result = try interactor.info(with: context)
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> InfoResultRenderer {
            return TextInfoResultRenderer()
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(InfoInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
