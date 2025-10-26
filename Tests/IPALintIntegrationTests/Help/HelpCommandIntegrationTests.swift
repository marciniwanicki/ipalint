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
import Foundation
import IPALintCommand
import IPALintCore
import Testing

@Suite("Help Command Integration Tests", .serialized)
struct HelpCommandIntegrationTests {
    private let expectedHelpOutput = """
    USAGE: ipalint <subcommand>

    OPTIONS:
      -h, --help              Show help information.

    SUBCOMMANDS:
      version                 Show version.
      snapshot                Create a snapshot file of a given .ipa package.
      lint                    Lint given ipa package.
      info                    Show info about the ipa package.
      diff                    Diff two ipa packages.

      See 'ipalint help <subcommand>' for detailed help.

    """

    @Test("Help command with --help flag")
    func help() {
        let context = IntegrationTestContext()
        defer { context.cleanup() }

        // When
        let exitCode = context.subject.run(with: ["--help"])

        // Then
        #expect(exitCode == 0)
        #expect(context.stdout == expectedHelpOutput)
    }

    @Test("Help command when no parameters provided")
    func helpWhenNoParameters() {
        let context = IntegrationTestContext()
        defer { context.cleanup() }

        // When
        let exitCode = context.subject.run(with: [])

        // Then
        #expect(exitCode == 0)
        #expect(context.stdout == expectedHelpOutput)
    }
}
