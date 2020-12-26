import Foundation
import IPALintCore

final class Resolver {
    var printer: Printer

    private var infoInteractor: InfoInteractor { factory.makeInfoInteractor() }
    private var lintInteractor: LintInteractor { factory.makeLintInteractor() }

    private let factory: Factory

    init() {
        printer = DefaultPrinter()
        factory = Factory()
    }

    func resolveInfoExecutor() -> InfoCommand.Executor {
        .init(infoInteractor: infoInteractor,
              printer: printer)
    }
}
