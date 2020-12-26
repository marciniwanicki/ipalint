//
//  SnapshotInteractor.swift
//  IPALintCommand
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public struct SnapshotContext {
    public let path: String?
    public let tempPath: String?

    public init(path: String?, tempPath: String?) {
        self.path = path
        self.tempPath = tempPath
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

        return .init()
    }
}
