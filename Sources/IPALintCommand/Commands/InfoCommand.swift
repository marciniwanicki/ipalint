//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import ArgumentParser
import Foundation
import IPALintCore
import SCInject
import TSCBasic

struct InfoCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "info",
        abstract: "Show info about the ipa package."
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

    @Flag(help: "Do not use colors in the output.")
    var noColors: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: InfoInteractor
        private let printer: Printer

        init(interactor: InfoInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: InfoCommand) throws {
            let context = InfoContext(ipaPath: command.path, tempPath: command.temp)
            let result = try interactor.info(with: context)
            renderer(colorsEnabled: !command.noColors).render(result: result)
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> InfoResultRenderer {
            TextInfoResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(
                    interactor: r.resolve(InfoInteractor.self),
                    printer: r.resolve(Printer.self)
                )
            }
        }
    }
}
