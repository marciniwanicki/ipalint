//
//  IPAFileInspector.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

protocol IPAFileInspector {
    func inspect(at path: AbsolutePath) throws -> IPAFile
}

protocol IPAFile {
    func fileSystemTree() throws -> FileSystemTree
}

final class DefaultIPAFileInspector: IPAFileInspector {
    private let system: System
    private let fileSystem: FileSystem
    private let archiver: Archiver

    init(system: System, fileSystem: FileSystem, archiver: Archiver) {
        self.system = system
        self.fileSystem = fileSystem
        self.archiver = archiver
    }

    func inspect(at path: AbsolutePath) throws -> IPAFile {
        // make temporary directory
        let temporaryDirectory = try fileSystem.makeTemporaryDirectory()

        // extract ipa file
        try archiver.extract(source: path, destination: temporaryDirectory.path)

        // prepare ipa file handler
        return DefaultIPAFile(fileSystem: fileSystem,
                              directory: temporaryDirectory)
    }
}

final class DefaultIPAFile: IPAFile {
    private let fileSystem: FileSystem
    private let directory: Directory

    init(fileSystem: FileSystem, directory: Directory) {
        self.fileSystem = fileSystem
        self.directory = directory
    }

    func fileSystemTree() throws -> FileSystemTree {
        try fileSystem.tree(at: directory.path)
    }
}
