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
        registry.register(Factory.self) { _ in
            Factory()
        }
    }
}

//final class Resolver2 {
//    var output: Output
//    var printer: Printer
//
//    private var infoInteractor: InfoInteractor { factory.makeInfoInteractor() }
//    private var lintInteractor: LintInteractor { factory.makeLintInteractor() }
//    private var diffInteractor: DiffInteractor { factory.makeDiffInteractor() }
//    private var snapshotInteractor: SnapshotInteractor { factory.makeSnapshotInteractor() }
//
//    private let factory: Factory
//
//    init() {
//        output = StandardOutput.shared
//        printer = DefaultPrinter(output: output)
//        factory = Factory()
//    }
//
//    func resolveMainExecutor() -> MainCommand.Executor {
//        .init(printer: printer)
//    }
//
//    func resolveInfoExecutor() -> InfoCommand.Executor {
//        .init(interactor: infoInteractor,
//              output: output)
//    }
//
//    func resolveDiffExecutor() -> DiffCommand.Executor {
//        .init(interactor: diffInteractor,
//              printer: printer)
//    }
//
//    func resolveSnapshotExecutor() -> SnapshotCommand.Executor {
//        .init(interactor: snapshotInteractor,
//              printer: printer)
//    }
//
//    func resolveLintExecutor() -> LintCommand.Executor {
//        .init(interactor: lintInteractor,
//              printer: printer)
//    }
//}
