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

    public init(path: String?) {
        self.path = path
    }
}

public struct InfoResult: Equatable {
    public enum Property: Equatable {
        case ipaPath(AbsolutePath)
        case ipaSize(FileSize)
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
        let ipaFile = try ipaFileInspector.inspect(at: ipaPath)
        let ipaSize = try fileSystem.fileSize(at: ipaPath)
        return InfoResult(properties: [
            .ipaPath(ipaPath),
            .ipaSize(ipaSize)
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
}
