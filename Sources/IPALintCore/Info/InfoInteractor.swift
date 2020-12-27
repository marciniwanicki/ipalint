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
    public enum Value: Equatable, CustomStringConvertible {
        case fileSize(FileSize)
        case string(String)
        case uint(UInt)
        case int(Int)

        public var description: String {
            switch self {
            case let .fileSize(value):
                return value.description
            case let .int(value):
                return value.description
            case let .string(value):
                return value
            case let .uint(value):
                return value.description
            }
        }
    }

    public let properties: [String: Value]
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
            "ipa_path": .string(ipaPath.pathString),
            "ipa_size": .fileSize(ipaSize),
            "number_of_files": .int(numberOfFiles)
        ])
    }
}
