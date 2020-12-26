//
//  IPAFileInspector.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

protocol IPAFileInspector {
    func inspect(at path: AbsolutePath, tempPath: AbsolutePath?) throws -> IPAFile
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

    func inspect(at path: AbsolutePath, tempPath: AbsolutePath?) throws -> IPAFile {
        // make temporary directory
        let tempDirectory = try directory(tempPath: tempPath)

        // extract ipa file
        try archiver.extract(source: path, destination: tempDirectory.path)

        // prepare ipa file handler
        return DefaultIPAFile(fileSystem: fileSystem,
                              directory: tempDirectory)
    }

    // MARK: - Private

    private func directory(tempPath: AbsolutePath?) throws -> Directory {
        if let tempPath = tempPath {
            let items = try fileSystem.list(at: tempPath)
            guard items.isEmpty else {
                throw CoreError.generic("Temporary directory is not empty (path=\(tempPath.pathString))")
            }
            return PredefinedDirectory(path: tempPath)
        } else {
            return try fileSystem.makeTemporaryDirectory()
        }
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
