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
import IPALintCore

protocol Printer {
    var output: Output { get }

    func text(_ message: String)
    func error(_ message: String)
}

final class DefaultPrinter: Printer {
    let output: Output

    init(output: Output) {
        self.output = output
    }

    func text(_ message: String) {
        output.write("\(message)\n", to: .stdout)
    }

    func error(_ message: String) {
        output.write("Error: \(message)\n", to: .stderr)
    }
}

extension Printer {
    func richTextOutput(colorsEnabled: Bool = true) -> RichTextOutput {
        TerminalRichTextOutput(output: output, colorsEnabled: colorsEnabled)
    }
}
