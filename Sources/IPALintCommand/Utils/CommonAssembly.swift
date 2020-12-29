import Foundation
import IPALintCore

final class CommonAssembly: Assembly {
    func assemble(_ registry: Registry) {
        registry.register(Output.self) { _ in
            StandardOutput.shared
        }
        registry.register(Printer.self) { r in
            DefaultPrinter(output: r.resolve(Output.self))
        }
    }
}
