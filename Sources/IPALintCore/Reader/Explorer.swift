//
//  IPAExplorer.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 06/06/2020.
//

import Foundation
import TSCBasic

public protocol IPAFileReader {
    func read(at path: AbsolutePath) throws
}


final class DefaultIPAFileReader: IPAFileReader {
    private let system: System
    private let fileSystem: FileSystem
    private let archiver: Archiver

    init(system: System, fileSystem: FileSystem, archiver: Archiver) {
        self.system = system
        self.fileSystem = fileSystem
        self.archiver = archiver
    }

    func read(at path: AbsolutePath) throws {
//        // make temporary directory
//        let temporaryDirectory = try fileSystem.makeTemporaryDirectory()
//
//        // extract ipa file
//        try archiver.extract(source: path, destination: temporaryDirectory.path)

        // Extracted
        let temporaryDirectory = AbsolutePath("/var/folders/d9/mzdncxbn4k73_5_72q0n0d0w0000gn/T/ipalint.F9L668/")

//        let list = try fileSystem.list(at: temporaryDirectory)
        let tree = try fileSystem.tree(at: temporaryDirectory)

        print(tree)
    }
}
