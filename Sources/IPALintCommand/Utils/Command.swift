import ArgumentParser
import Foundation
import IPALintCore

protocol CommandExecutor {
    associatedtype Command

    func execute(command: Command) throws
}

protocol Command: ParsableCommand {
    associatedtype Executor: CommandExecutor where Executor.Command == Self
}

extension Command {
    func run() throws {
        try resolver.resolve(Executor.self).execute(command: self)
    }
}

protocol CommandAssembly: Assembly {}
