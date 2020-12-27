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
    private let contentExtractor: ContentExtractor

    init(fileSystem: FileSystem,
         contentExtractor: ContentExtractor) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
    }

    func info(with context: InfoContext) throws -> InfoResult {
        let content = try contentExtractor.content(from: context)
        let allFilesIterator = try fileSystem.tree(at: content.temporaryDirectory.path).allFilesIterator()
        let ipaSize = try fileSystem.fileSize(at: content.ipaPath)
        let numberOfFiles = allFilesIterator.all().count
        return InfoResult(properties: [
            "ipa_path": .string(content.ipaPath.pathString),
            "ipa_size": .fileSize(ipaSize),
            "number_of_files": .int(numberOfFiles)
        ])
    }
}
