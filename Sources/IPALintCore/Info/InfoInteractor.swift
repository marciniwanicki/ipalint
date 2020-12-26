//
//  InfoInteractor.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

public struct InfoContext {
    public let path: String?
    public let tempPath: String?

    public init(path: String?, tempPath: String?) {
        self.path = path
        self.tempPath = tempPath
    }
}

public struct InfoResult: Equatable {
    public enum Property: Equatable {
        case ipaPath(AbsolutePath)
        case ipaSize(FileSize)
        case numberOfFiles(UInt)
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
        let ipaPath = try findIPAFilePath(with: context)
        let tempPath = try tempDirectoryPath(from: context.tempPath)
        let ipaSize = try fileSystem.fileSize(at: ipaPath)
        let ipaFile = try ipaFileInspector.inspect(at: ipaPath, tempPath: tempPath)
        let fileSystemTree = try ipaFile.fileSystemTree()
        let allFilesIterator = AllFilesIterator(fileSystemTree: fileSystemTree)

        var count: UInt = 0
        allFilesIterator.forEach { _ in
            count += 1
        }

        return InfoResult(properties: [
            .ipaPath(ipaPath),
            .ipaSize(ipaSize),
            .numberOfFiles(count)
        ])
    }

    // MARK: - Private

    // TODO: Move it to a better place
    private func findIPAFilePath(with context: InfoContext) throws -> AbsolutePath {
        if let path = context.path {
            return try fileSystem.absolutePath(from: path)
        }

        let items: [AbsolutePath] = try fileSystem.list(at: fileSystem.currentWorkingDirectory)
            .compactMap {
                if case let .file(file) = $0, file.path.extension == "ipa" {
                    return fileSystem.currentWorkingDirectory.appending(file.path)
                }
                return nil
            }

        guard !items.isEmpty else {
            throw CoreError.generic("Did find any .ipa files in the current directory.")
        }
        guard items.count == 1 else {
            throw CoreError.generic("Found more than one (\(items.count)) in the current directory.")
        }
        return items[0]
    }

    private func tempDirectoryPath(from path: String?) throws -> AbsolutePath? {
        if let path = path {
            return try fileSystem.absolutePath(from: path)
        }
        return nil
    }
}
