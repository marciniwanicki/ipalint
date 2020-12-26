//
//  Factory.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public enum RendererType {
    case text
}

public final class Factory {
    var system: System
    var fileSystem: FileSystem
    var archiver: Archiver
    var ipaFileInspector: IPAFileInspector

    public init() {
        system = DefaultSystem()
        fileSystem = DefaultFileSystem()
        archiver = TarArchiver(system: system)
        ipaFileInspector = DefaultIPAFileInspector(system: system,
                                                   fileSystem: fileSystem,
                                                   archiver: archiver)
    }

    public func makeInfoInteractor() -> InfoInteractor {
        DefaultInfoInteractor(fileSystem: fileSystem,
                              ipaFileInspector: ipaFileInspector)
    }

    public func makeLintInteractor() -> LintInteractor {
        DefaultLintInteractor()
    }

    public func makeDiffInteractor() -> DiffInteractor {
        DefaultDiffInteractor()
    }

    public func makeSnapshotInteractor() -> SnapshotInteractor {
        DefaultSnapshotInteractor(fileSystem: fileSystem,
                                  ipaFileInspector: ipaFileInspector)
    }
}
