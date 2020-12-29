import Foundation
import XCTest

@testable import IPALintCore

final class FileSizeTests: XCTestCase {
    func testInitWithString() {
        // Invalid
        XCTAssertNil(FileSize(string: ""))
        XCTAssertNil(FileSize(string: "1-"))
        XCTAssertNil(FileSize(string: "1B"))
        XCTAssertNil(FileSize(string: "1B-"))
        XCTAssertNil(FileSize(string: "+1B"))
        XCTAssertNil(FileSize(string: "1 TB")) // not supported

        // Valid
        XCTAssertEqual(FileSize(string: "1 B")?.bytes, 1)
        XCTAssertEqual(FileSize(string: "1 KB")?.bytes, 1 << 10)
        XCTAssertEqual(FileSize(string: "1 MB")?.bytes, 1 << 20)
        XCTAssertEqual(FileSize(string: "32 MB")?.bytes, 1 << 25)
        XCTAssertEqual(FileSize(string: "1 GB")?.bytes, 1 << 30)
    }

    func testDescription() {
        XCTAssertEqual(FileSize(bytes: 0).description, "0 B")
        XCTAssertEqual(FileSize(bytes: 1).description, "1 B")
        XCTAssertEqual(FileSize(bytes: 100).description, "100 B")
        XCTAssertEqual(FileSize(bytes: 1000).description, "1000 B")
        XCTAssertEqual(FileSize(bytes: 1023).description, "1023 B")
        XCTAssertEqual(FileSize(bytes: 1024).description, "1.00 KB")
        XCTAssertEqual(FileSize(bytes: 1024 + 256).description, "1.25 KB")
        XCTAssertEqual(FileSize(bytes: 1024 + 512).description, "1.50 KB")
        XCTAssertEqual(FileSize(bytes: 1 << 20 - 1).description, "1024.00 KB") // rounded
        XCTAssertEqual(FileSize(bytes: 1 << 20).description, "1.00 MB")
        XCTAssertEqual(FileSize(bytes: 1 << 25).description, "32.00 MB")
        XCTAssertEqual(FileSize(bytes: 1 << 30 - 1).description, "1024.00 MB")
        XCTAssertEqual(FileSize(bytes: 1 << 30).description, "1.00 GB")
    }

    func testCompare() {
        XCTAssertEqual(FileSize(bytes: 0), FileSize(bytes: 0))
        XCTAssertEqual(FileSize(bytes: 1), FileSize(bytes: 1))
        XCTAssertEqual(FileSize(bytes: 1024), FileSize(bytes: 1024))

        XCTAssertTrue(FileSize(bytes: 1) > FileSize(bytes: 0))
        XCTAssertTrue(FileSize(bytes: 2) > FileSize(bytes: 1))
        XCTAssertFalse(FileSize(bytes: 1) > FileSize(bytes: 1))
        XCTAssertTrue(FileSize(bytes: 1) >= FileSize(bytes: 1))
    }

    func testDelta() {
        XCTAssertEqual(FileSize(bytes: 1).delta(FileSize(bytes: 1)).description, "0")

        XCTAssertEqual(FileSize(bytes: 5).delta(FileSize(bytes: 1)).description, "-4 B")
        XCTAssertEqual(FileSize(bytes: 1).delta(FileSize(bytes: 5)).description, "+4 B")

        XCTAssertEqual(FileSize(bytes: 1 << 25).delta(FileSize(bytes: 1 << 20)).description, "-31.00 MB")
        XCTAssertEqual(FileSize(bytes: 1 << 20).delta(FileSize(bytes: 1 << 25)).description, "+31.00 MB")
    }
}
