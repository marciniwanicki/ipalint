import Foundation

public final class CoreAssembly: Assembly {
    // MARK: - Init

    public init() {}

    // MARK: - Assembly

    public func assemble(_ registry: Registry) {
        assembleRules(registry)
        assembleUtils(registry)
        assembleInteractors(registry)
    }

    // MARK: - Private

    private func assembleRules(_ registry: Registry) {
        registry.register([TypedLintRule].self) { r in
            [
                .file(IPAFileSizeLintRule(fileSystem: r.resolve(FileSystem.self))),
                .content(PayloadSizeLintRule(fileSystem: r.resolve(FileSystem.self))),
            ]
        }
    }

    private func assembleUtils(_ registry: Registry) {
        registry.register(System.self) { _ in
            DefaultSystem()
        }
        registry.register(FileSystem.self) { _ in
            DefaultFileSystem()
        }
        registry.register(Archiver.self) { r in
            TarArchiver(system: r.resolve(System.self))
        }
        registry.register(ContentExtractor.self) { r in
            DefaultContentExtractor(system: r.resolve(System.self),
                                    fileSystem: r.resolve(FileSystem.self),
                                    archiver: r.resolve(Archiver.self))
        }
        registry.register(CodesignExtractor.self) { r in
            DefaultCodesignExtractor(system: r.resolve(System.self))
        }
        registry.register(Crypto.self) { _ in
            DefaultCrypto()
        }
        registry.register(SnapshotGenerator.self) { r in
            DefaultSnapshotGenerator(fileSystem: r.resolve(FileSystem.self),
                                     crypto: r.resolve(Crypto.self))
        }
        registry.register(SnapshotParser.self) { r in
            DefaultSnapshotParser(fileSystem: r.resolve(FileSystem.self))
        }
        registry.register(ConfigurationLoader.self) { r in
            YamlConfigurationLoader(fileSystem: r.resolve(FileSystem.self))
        }
    }

    private func assembleInteractors(_ registry: Registry) {
        registry.register(InfoInteractor.self) { r in
            DefaultInfoInteractor(fileSystem: r.resolve(FileSystem.self),
                                  contentExtractor: r.resolve(ContentExtractor.self),
                                  codesignExtractor: r.resolve(CodesignExtractor.self))
        }
        registry.register(DiffInteractor.self) { r in
            DefaultDiffInteractor(fileSystem: r.resolve(FileSystem.self),
                                  contentExtractor: r.resolve(ContentExtractor.self),
                                  snapshotGenerator: r.resolve(SnapshotGenerator.self),
                                  snapshotParser: r.resolve(SnapshotParser.self))
        }
        registry.register(SnapshotInteractor.self) { r in
            DefaultSnapshotInteractor(fileSystem: r.resolve(FileSystem.self),
                                      contentExtractor: r.resolve(ContentExtractor.self),
                                      snapshotGenerator: r.resolve(SnapshotGenerator.self),
                                      snapshotParser: r.resolve(SnapshotParser.self))
        }
        registry.register(LintInteractor.self) { r in
            DefaultLintInteractor(fileSystem: r.resolve(FileSystem.self),
                                  contentExtractor: r.resolve(ContentExtractor.self),
                                  codesignExtractor: r.resolve(CodesignExtractor.self),
                                  configurationLoader: r.resolve(ConfigurationLoader.self),
                                  rules: r.resolve([TypedLintRule].self))
        }
    }
}
