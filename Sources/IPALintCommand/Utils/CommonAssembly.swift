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
