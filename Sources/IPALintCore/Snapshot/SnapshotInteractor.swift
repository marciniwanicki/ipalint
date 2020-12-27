//
//  SnapshotInteractor.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public struct SnapshotContext {
    public let ipaPath: String?
    public let tempPath: String?
    public let outputPath: String?

    public init(ipaPath: String?, tempPath: String?, outputPath: String?) {
        self.ipaPath = ipaPath
        self.tempPath = tempPath
        self.outputPath = outputPath
    }
}

public struct SnapshotResult {

}

public protocol SnapshotInteractor {
    func snapshot(with context: SnapshotContext) throws -> SnapshotResult
}

final class DefaultSnapshotInteractor: SnapshotInteractor {
    private let fileSystem: FileSystem
    private let ipaFileInspector: IPAFileInspector

    init(fileSystem: FileSystem,
         ipaFileInspector: IPAFileInspector) {
        self.fileSystem = fileSystem
        self.ipaFileInspector = ipaFileInspector
    }

    func snapshot(with context: SnapshotContext) throws -> SnapshotResult {
        let ipaPath = try fileSystem.ipaFilePath(from: context)
        let tempPath = try fileSystem.tempDirectoryPath(from: context)

        return .init()
    }
}
