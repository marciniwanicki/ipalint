//
//  TestMeCommand.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import ArgumentParser
import Foundation
import IPALintCore
import TSCBasic

struct InfoCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "info",
        abstract: "Shows info about the ipa package."
    )

    func run() throws {
        try Executor(printer: r.printer).execute(command: self)
    }

    final class Executor {
        private let printer: Printer

        init(printer: Printer) {
            self.printer = printer
        }

        func execute(command: InfoCommand) throws {
            let path = AbsolutePath("/Users/marcin/Desktop/BBA-2.2020b1.ipa")
            let factory = Factory()
            let ipaFileReader = factory.makeIPAFileReader()
            try ipaFileReader.read(at: path)
        }
    }
}
