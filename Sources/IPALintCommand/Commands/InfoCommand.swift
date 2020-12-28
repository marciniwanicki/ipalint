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

    func run() throws {
//        try r.resolveInfoExecutor().execute(command: self)
    }

    private func context() -> InfoContext {
        .init(ipaPath: path,
              tempPath: temp)
    }

    final class Executor {
        private let interactor: InfoInteractor
        private let output: Output

        init(interactor: InfoInteractor, output: Output) {
            self.interactor = interactor
            self.output = output
        }

        func execute(command: InfoCommand) throws {
            let result = try interactor.info(with: command.context())
            renderer().render(result: result, to: output)
        }

        // MARK: - Private

        private func renderer() -> InfoResultRenderer {
            return TextInfoResultRenderer()
        }
    }
}
