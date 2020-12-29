import ArgumentParser
import Foundation
import IPALintCore

protocol CommandExecutor {
    associatedtype Command

//    func execute(with context: Context) throws

    func execute(with command: Command) throws
}

protocol Command: ParsableCommand {
    associatedtype Executor: CommandExecutor where Executor.Command == Self

//    func context() -> Executor.Context
}

extension Command {
    func run() throws {
//        try resolver.resolve(Executor.self).execute(with: context())

        try resolver.resolve(Executor.self).execute(with: self)
    }
}

protocol CommandAssembly: Assembly {}
