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

struct LintCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "lint",
        abstract: "Lint given ipa package."
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
        help: "Path to config file.",
        completion: .directory
    )
    var config: String?

    @Flag(help: "Do not use colors in the output.")
    var noColors: Bool = false

    @Flag(help: "Treat warnings as errors.")
    var strict: Bool = false

    final class Executor: CommandExecutor {
        private let interactor: LintInteractor
        private let printer: Printer

        init(interactor: LintInteractor, printer: Printer) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: LintCommand) throws {
            let context = LintContext(
                ipaPath: command.path,
                tempPath: command.temp,
                configPath: command.config
            )
            let result = try interactor.lint(with: context)

            renderer(colorsEnabled: !command.noColors).render(result: result)

            guard !result.hasError else {
                throw exit(1)
            }
            guard !result.hasWarning || !command.strict else {
                throw exit(1)
            }
        }

        // MARK: - Private

        private func renderer(colorsEnabled: Bool) -> LintResultRenderer {
            TextLintResultRenderer(output: printer.richTextOutput(colorsEnabled: colorsEnabled))
        }
    }

    final class Assembly: CommandAssembly {
        func assemble(_ registry: Registry) {
            registry.register(Executor.self) { r in
                Executor(
                    interactor: r.resolve(LintInteractor.self),
                    printer: r.resolve(Printer.self)
                )
            }
        }
    }
}
