import Foundation
import IPALintCommand
import IPALintCore
import XCTest

class IntegrationTestCase: XCTestCase {
    let subject = CommandRunner()

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {
        output.clear()
    }

    // MARK: - Helpers

    var stdout: String {
        output.stdout.joined()
    }

    var output: CaptureOutput {
        CaptureOutput.tests
    }
}
