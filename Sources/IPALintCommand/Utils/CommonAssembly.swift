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
import SCInject

final class CommonAssembly: Assembly {
    func assemble(_ registry: Registry) {
        registry.register(Output.self) { _ in
            #if DEBUG
                return CombinedOutput(outputs: [StandardOutput.shared, CaptureOutput.tests])
            #else
                return StandardOutput.shared
            #endif
        }
        registry.register(Printer.self) { r in
            DefaultPrinter(output: r.resolve(Output.self))
        }
    }
}
