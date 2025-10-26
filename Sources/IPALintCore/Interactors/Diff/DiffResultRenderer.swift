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

public protocol DiffResultRenderer {
    func render(result: DiffResult)
}

public final class TextDiffResultRenderer: DiffResultRenderer {
    private let output: RichTextOutput

    public init(output: RichTextOutput) {
        self.output = output
    }

    public func render(result: DiffResult) {
        for diff in result.diff.differences {
            switch diff {
            case let .onlyInFirst(file):
                output.write(
                    .text("- \(file.path) \(file.size)", .color(.red)) + .text(" (only in first)\n", .color(.darkGray)),
                )
            case let .onlyInSecond(file):
                output.write(
                    .text("+ \(file.path) \(file.size)", .color(.green)) +
                        .text(" (only in second)\n", .color(.darkGray)),
                )
            case let .difference(difference):
                output.write(
                    .text("* \(difference.path) (different content Δ \(difference.deltaFileSize))\n", .color(.yellow))
                        + .text("  1) \(difference.firstSize) (\(difference.firstSha256))\n", .color(.yellow))
                        + .text("  2) \(difference.secondSize) (\(difference.secondSha256))\n", .color(.yellow)),
                )
            }
        }
    }
}
