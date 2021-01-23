import ArgumentParser
import Foundation
import IPALintCore

private enum Setup {
    static let allSubcommands: [(ParsableCommand.Type, Assembly)] = [
        (VersionCommand.self, VersionCommand.Assembly()),
        (SnapshotCommand.self, SnapshotCommand.Assembly()),
        (LintCommand.self, LintCommand.Assembly()),
        (InfoCommand.self, InfoCommand.Assembly()),
        (DiffCommand.self, DiffCommand.Assembly()),
    ]
}

extension Command {
    var resolver: Resolver {
        Assembler(container: DefaultContainer())
            .assemble(commonAssemblies)
            .assemble(commandAssemblies)
            .assemble(coreAssemblies)
            .resolver()
    }

    // MARK: - Assemblies

    private var commonAssemblies: [Assembly] {
        [
            CommonAssembly(),
        ]
    }

    private var commandAssemblies: [Assembly] {
        Setup.allSubcommands.map { $0.1 }
    }

    private var coreAssemblies: [Assembly] {
        [
            CoreAssembly(),
        ]
    }
}

extension ParsableCommand {
    static var allSubcommands: [ParsableCommand.Type] {
        Setup.allSubcommands.map { $0.0 }
    }
}
