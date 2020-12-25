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

struct TestMeCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "test",
        abstract: "Just testing stuff.."
    )

    func run() {
        do {
            try testMe()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func testMe() throws {
        let path = AbsolutePath("/Users/marcin/Desktop/BBA-2.2020b1.ipa")
        let factory = Factory()
        let ipaFileReader = factory.makeIPAFileReader()
        try ipaFileReader.read(at: path)
    }
}

