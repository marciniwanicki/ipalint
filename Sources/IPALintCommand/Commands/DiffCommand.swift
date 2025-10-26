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

struct DiffCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "diff",
        abstract: "Diff two ipa packages.",
    )

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory,
    )
    var path1: String

    @Option(
        name: .long,
        help: "Path to the first .ipa file.",
        completion: .directory,
    )
    var path2: String

    @Flag
    var noColors: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: DiffInteractor
        private let printer: Printer

        init(
            interactor: DiffInteractor,
            printer: Printer,
        ) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: DiffCommand) throws {
            let context = DiffContext(path1: command.path1, path2: command.path2)
            let result = try interactor.diff(with: context)
            renderer(colorsEnabled: !command.noColors).render(result: result)
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> DiffResultRenderer {
            TextDiffResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(
                    interactor: r.resolve(DiffInteractor.self),
                    printer: r.resolve(Printer.self),
                )
            }
        }
    }
}
