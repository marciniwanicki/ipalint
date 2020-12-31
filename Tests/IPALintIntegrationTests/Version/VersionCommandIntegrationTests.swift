import Foundation
import IPALintCommand
import IPALintCore
import XCTest

final class VersionCommandIntegrationTests: IntegrationTestCase {
    func testVersion() {
        // When
        let exitCode = subject.run(with: ["version"])

        // Then
        XCTAssertEqual(exitCode, 0)
        XCTAssertEqual(stdout, "0.1.0+debug.local\n")
    }
}
