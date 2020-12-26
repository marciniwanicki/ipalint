//
//  InfoInteractor.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

public struct InfoContext {
    public let ipaPath: String?
    public let tempPath: String?

    public init(ipaPath: String?, tempPath: String?) {
        self.ipaPath = ipaPath
        self.tempPath = tempPath
    }
}

public struct InfoResult: Equatable {
    public enum Property: Equatable {
        case ipaSize(FileSize)
        case string(String, String)
        case uint(String, UInt)
        case int(String, Int)
    }

    public let properties: [Property]
}

public protocol InfoInteractor {
    func info(with context: InfoContext) throws -> InfoResult
}

final class DefaultInfoInteractor: InfoInteractor {
    private let fileSystem: FileSystem
    private let ipaFileInspector: IPAFileInspector

    init(fileSystem: FileSystem,
         ipaFileInspector: IPAFileInspector) {
        self.fileSystem = fileSystem
        self.ipaFileInspector = ipaFileInspector
    }

    func info(with context: InfoContext) throws -> InfoResult {
        let ipaPath = try fileSystem.ipaFilePath(from: context)
        let tempPath = try fileSystem.tempDirectoryPath(from: context)
        let ipaSize = try fileSystem.fileSize(at: ipaPath)
        let ipaFile = try ipaFileInspector.inspect(at: ipaPath, tempPath: tempPath)
        let fileSystemTree = try ipaFile.fileSystemTree()
        let allFilesIterator = AllFilesIterator(fileSystemTree: fileSystemTree)
        let numberOfFiles = allFilesIterator.all().count
        return InfoResult(properties: [
            .string("ipa_path", ipaPath.pathString),
            .ipaSize(ipaSize),
            .int("number_of_files", numberOfFiles)
        ])
    }
}
