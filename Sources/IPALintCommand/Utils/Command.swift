//
//  Command.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 28/12/2020.
//

import Foundation
import ArgumentParser
import IPALintCore

protocol CommandExecutor {
    associatedtype Context

    func execute(with context: Context) throws
}

protocol Command: ParsableCommand {
    associatedtype Executor: CommandExecutor

    func context() -> Executor.Context
}

extension Command {
    func run() throws {
        try resolver.resolve(Executor.self).execute(with: context())
    }
}

protocol CommandAssembly: Assembly {}
