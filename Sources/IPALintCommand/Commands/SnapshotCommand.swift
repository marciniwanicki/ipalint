//
//  SnapshotCommand.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

struct SnapshotCommand: Command {
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

    func context() -> SnapshotContext {
        .init(ipaPath: path,
              tempPath: temp,
              outputPath: output)
    }

    final class Executor: CommandExecutor {
        private let interactor: SnapshotInteractor
        private let printer: Printer

        init(interactor: SnapshotInteractor,
             printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(with context: SnapshotContext) throws {
            let result = try interactor.snapshot(with: context)
            renderer().render(result: result, to: printer.output)
        }

        // MARK: - Private

        private func renderer() -> SnapshotResultRenderer {
            TextSnapshotResultRenderer()
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(interactor: r.resolve(SnapshotInteractor.self),
                         printer: r.resolve(Printer.self))
            }
        }
    }
}
