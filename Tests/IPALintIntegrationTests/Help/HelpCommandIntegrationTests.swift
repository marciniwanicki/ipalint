import Foundation
import IPALintCommand
import IPALintCore
import XCTest

final class HelpCommandIntegrationTests: IntegrationTestCase {
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

    func testHelp() {
        // When
        let exitCode = subject.run(with: ["--help"])

        // Then
        XCTAssertEqual(exitCode, 0)
        XCTAssertEqual(stdout, expectedHelpOutput)
    }

    func testHelpWhenNoParameters() {
        // When
        let exitCode = subject.run(with: [])

        // Then
        XCTAssertEqual(exitCode, 0)
        XCTAssertEqual(stdout, expectedHelpOutput)
    }
}
