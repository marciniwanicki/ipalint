import Foundation
import IPALintCore

final class Resolver {
    var output: Output
    var printer: Printer

    private var infoInteractor: InfoInteractor { factory.makeInfoInteractor() }
    private var lintInteractor: LintInteractor { factory.makeLintInteractor() }
    private var diffInteractor: DiffInteractor { factory.makeDiffInteractor() }
    private var snapshotInteractor: SnapshotInteractor { factory.makeSnapshotInteractor() }

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
        .init(interactor: infoInteractor,
              output: output)
    }

    func resolveDiffExecutor() -> DiffCommand.Executor {
        .init(interactor: diffInteractor,
              printer: printer)
    }

    func resolveSnapshotExecutor() -> SnapshotCommand.Executor {
        .init(interactor: snapshotInteractor,
              printer: printer)
    }
}
