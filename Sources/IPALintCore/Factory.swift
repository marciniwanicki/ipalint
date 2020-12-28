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
    var contentExtractor: ContentExtractor
    var crypto: Crypto
    var snapshotGenerator: SnapshotGenerator
    var snapshotParser: SnapshotParser

    public init() {
        system = DefaultSystem()
        fileSystem = DefaultFileSystem()
        archiver = TarArchiver(system: system)
        contentExtractor = DefaultContentExtractor(
            system: system,
            fileSystem: fileSystem,
            archiver: archiver
        )
        crypto = DefaultCrypto()
        snapshotGenerator = DefaultSnapshotGenerator(fileSystem: fileSystem, crypto: crypto)
        snapshotParser = DefaultSnapshotParser(fileSystem: fileSystem)
    }

    public func makeInfoInteractor() -> InfoInteractor {
        DefaultInfoInteractor(fileSystem: fileSystem,
                              contentExtractor: contentExtractor)
    }

    public func makeLintInteractor() -> LintInteractor {
        DefaultLintInteractor()
    }

    public func makeDiffInteractor() -> DiffInteractor {
        DefaultDiffInteractor(fileSystem: fileSystem,
                              contentExtractor: contentExtractor,
                              snapshotGenerator: snapshotGenerator,
                              snapshotParser: snapshotParser)
    }

    public func makeSnapshotInteractor() -> SnapshotInteractor {
        DefaultSnapshotInteractor(fileSystem: fileSystem,
                                  contentExtractor: contentExtractor,
                                  snapshotGenerator: snapshotGenerator,
                                  snapshotParser: snapshotParser)
    }
}
