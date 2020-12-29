import ArgumentParser
import Foundation
import IPALintCore

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
        [
            VersionCommand.Assembly(),
            SnapshotCommand.Assembly(),
            LintCommand.Assembly(),
            InfoCommand.Assembly(),
            DiffCommand.Assembly(),
        ]
    }

    private var coreAssemblies: [Assembly] {
        [
            CoreAssembly(),
        ]
    }
}

extension ParsableCommand {
    static var allSubcommands: [ParsableCommand.Type] {
        [
            VersionCommand.self,
            SnapshotCommand.self,
            LintCommand.self,
            InfoCommand.self,
            DiffCommand.self,
        ]
    }
}
