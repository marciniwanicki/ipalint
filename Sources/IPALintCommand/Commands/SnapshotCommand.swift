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

struct SnapshotCommand: Command {
    static let configuration: CommandConfiguration = .init(
        commandName: "snapshot",
        abstract: "Create a snapshot file of a given .ipa package."
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

    final class Executor: CommandExecutor {
        private let interactor: SnapshotInteractor
        private let printer: Printer

        init(
            interactor: SnapshotInteractor,
            printer: Printer
        ) {
            self.interactor = interactor
            self.printer = printer
        }

        func execute(command: SnapshotCommand) throws {
            let context = SnapshotContext(
                ipaPath: command.path,
                tempPath: command.temp,
                outputPath: command.output
            )
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
                Executor(
                    interactor: r.resolve(SnapshotInteractor.self),
                    printer: r.resolve(Printer.self)
                )
            }
        }
    }
}
