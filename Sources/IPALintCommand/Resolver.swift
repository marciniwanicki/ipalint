import Foundation
import IPALintCore

final class Resolver {
    var output: Output
    var printer: Printer

    private var infoInteractor: InfoInteractor { factory.makeInfoInteractor() }
    private var lintInteractor: LintInteractor { factory.makeLintInteractor() }

    private let factory: Factory

    init() {
        output = StandardOutput.shared
        printer = DefaultPrinter(output: output)
        factory = Factory()
    }

    func resolveMainExecutor() -> MainCommand.Executor {
        .init(printer: printer)
    }

    func resolveInfoExecutor() -> InfoCommand.Executor {
        .init(infoInteractor: infoInteractor,
              output: output)
    }
}
