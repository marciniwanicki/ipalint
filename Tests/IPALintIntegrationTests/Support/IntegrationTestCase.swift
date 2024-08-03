import Foundation
import IPALintCommand
import IPALintCore
import XCTest

class IntegrationTestCase: XCTestCase {
    let subject = CommandRunner()
    let fixtures = Fixtures()

    override func setUpWithError() throws {
        try fixtures.setUp()
    }

    override func tearDownWithError() throws {
        try fixtures.tearDown()
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
