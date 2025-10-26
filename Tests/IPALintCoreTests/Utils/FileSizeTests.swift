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
import Testing

@testable import IPALintCore

@Suite("FileSize Tests")
struct FileSizeTests {
    @Test("Initialize FileSize with string")
    func initWithString() {
        // Invalid
        #expect(FileSize(string: "") == nil)
        #expect(FileSize(string: "1-") == nil)
        #expect(FileSize(string: "1B") == nil)
        #expect(FileSize(string: "1B-") == nil)
        #expect(FileSize(string: "+1B") == nil)
        #expect(FileSize(string: "1 TB") == nil) // not supported

        // Valid
        #expect(FileSize(string: "1 B")?.bytes == 1)
        #expect(FileSize(string: "1 KB")?.bytes == 1 << 10)
        #expect(FileSize(string: "1 MB")?.bytes == 1 << 20)
        #expect(FileSize(string: "32 MB")?.bytes == 1 << 25)
        #expect(FileSize(string: "1 GB")?.bytes == 1 << 30)
    }

    @Test("FileSize description")
    func description() {
        #expect(FileSize(bytes: 0).description == "0 B")
        #expect(FileSize(bytes: 1).description == "1 B")
        #expect(FileSize(bytes: 100).description == "100 B")
        #expect(FileSize(bytes: 1000).description == "1000 B")
        #expect(FileSize(bytes: 1023).description == "1023 B")
        #expect(FileSize(bytes: 1024).description == "1.00 KB")
        #expect(FileSize(bytes: 1024 + 256).description == "1.25 KB")
        #expect(FileSize(bytes: 1024 + 512).description == "1.50 KB")
        #expect(FileSize(bytes: 1 << 20 - 1).description == "1024.00 KB") // rounded
        #expect(FileSize(bytes: 1 << 20).description == "1.00 MB")
        #expect(FileSize(bytes: 1 << 25).description == "32.00 MB")
        #expect(FileSize(bytes: 1 << 30 - 1).description == "1024.00 MB")
        #expect(FileSize(bytes: 1 << 30).description == "1.00 GB")
    }

    @Test("Compare FileSizes")
    func compare() {
        #expect(FileSize(bytes: 0) == FileSize(bytes: 0))
        #expect(FileSize(bytes: 1) == FileSize(bytes: 1))
        #expect(FileSize(bytes: 1024) == FileSize(bytes: 1024))

        #expect(FileSize(bytes: 1) > FileSize(bytes: 0))
        #expect(FileSize(bytes: 2) > FileSize(bytes: 1))
        #expect(!(FileSize(bytes: 1) > FileSize(bytes: 1)))
        #expect(FileSize(bytes: 1) >= FileSize(bytes: 1))
    }

    @Test("FileSize delta")
    func delta() {
        #expect(FileSize(bytes: 1).delta(FileSize(bytes: 1)).description == "0")

        #expect(FileSize(bytes: 5).delta(FileSize(bytes: 1)).description == "-4 B")
        #expect(FileSize(bytes: 1).delta(FileSize(bytes: 5)).description == "+4 B")

        #expect(FileSize(bytes: 1 << 25).delta(FileSize(bytes: 1 << 20)).description == "-31.00 MB")
        #expect(FileSize(bytes: 1 << 20).delta(FileSize(bytes: 1 << 25)).description == "+31.00 MB")
    }
}
