//
//  IPAFileInspector.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

protocol ContentExtractor {
    func content(from context: HasIPAPath & HasTempPath) throws -> IPAContent
}

final class DefaultContentExtractor: ContentExtractor {
    private let system: System
    private let fileSystem: FileSystem
    private let archiver: Archiver

    init(system: System, fileSystem: FileSystem, archiver: Archiver) {
        self.system = system
        self.fileSystem = fileSystem
        self.archiver = archiver
    }

    func content(from context: HasIPAPath & HasTempPath) throws -> IPAContent {
        let ipaPath = try fileSystem.ipaFilePath(from: context)
        let tempDirOptionalPath = try context.tempPath.map { try fileSystem.absolutePath(from: $0) }
        let temporaryDirectory = try fileSystem.temporaryDirectory(at: tempDirOptionalPath)

        try archiver.extract(source: ipaPath, destination: temporaryDirectory.path)

        return IPAContent(ipaPath: ipaPath, temporaryDirectory: temporaryDirectory)
    }
}

final class IPAContent {
    let ipaPath: AbsolutePath
    let temporaryDirectory: Directory

    init(ipaPath: AbsolutePath, temporaryDirectory: Directory) {
        self.ipaPath = ipaPath
        self.temporaryDirectory = temporaryDirectory
    }
}
