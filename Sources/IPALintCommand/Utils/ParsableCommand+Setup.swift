//
//  ParsableCommand+Extensions.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

extension ParsableCommand {
    var resolver: Resolver {
        Assembler(container: DefaultContainer())
            .assemble(commonAssemblies)
            .assemble(commandAssemblies)
            .assemble(coreAssemblies)
            .container()
    }

    // MARK: - Subcommands

    static var allSubcommands: [ParsableCommand.Type] {
        [
            VersionCommand.self,
            SnapshotCommand.self,
            LintCommand.self,
            InfoCommand.self,
        ]
    }

    // MARK: - Assemblies

    private var commonAssemblies: [Assembly] {
        [
            CommonAssembly()
        ]
    }

    private var commandAssemblies: [Assembly] {
        [
            VersionCommand.Assembly(),
            SnapshotCommand.Assembly(),
            LintCommand.Assembly(),
            InfoCommand.Assembly(),
        ]
    }

    private var coreAssemblies: [Assembly] {
        [
            CoreAssembly()
        ]
    }
}
