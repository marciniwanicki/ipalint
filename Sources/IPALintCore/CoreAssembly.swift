//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import SCInject

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
                .content(EntitlementsLintRule(codesignExtractor: r.resolve(CodesignExtractor.self))),
                .content(FrameworksLintRule(fileSystem: r.resolve(FileSystem.self))),
                .fileSystemTree(FileExtensionsLintRule()),
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
            DefaultContentExtractor(
                system: r.resolve(System.self),
                fileSystem: r.resolve(FileSystem.self),
                archiver: r.resolve(Archiver.self),
            )
        }
        registry.register(CodesignExtractor.self) { r in
            DefaultCodesignExtractor(system: r.resolve(System.self))
        }
        registry.register(Crypto.self) { _ in
            DefaultCrypto()
        }
        registry.register(SnapshotGenerator.self) { r in
            DefaultSnapshotGenerator(
                fileSystem: r.resolve(FileSystem.self),
                crypto: r.resolve(Crypto.self),
            )
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
            DefaultInfoInteractor(
                fileSystem: r.resolve(FileSystem.self),
                contentExtractor: r.resolve(ContentExtractor.self),
                codesignExtractor: r.resolve(CodesignExtractor.self),
            )
        }
        registry.register(DiffInteractor.self) { r in
            DefaultDiffInteractor(
                fileSystem: r.resolve(FileSystem.self),
                contentExtractor: r.resolve(ContentExtractor.self),
                snapshotGenerator: r.resolve(SnapshotGenerator.self),
                snapshotParser: r.resolve(SnapshotParser.self),
            )
        }
        registry.register(SnapshotInteractor.self) { r in
            DefaultSnapshotInteractor(
                fileSystem: r.resolve(FileSystem.self),
                contentExtractor: r.resolve(ContentExtractor.self),
                snapshotGenerator: r.resolve(SnapshotGenerator.self),
                snapshotParser: r.resolve(SnapshotParser.self),
            )
        }
        registry.register(LintInteractor.self) { r in
            DefaultLintInteractor(
                fileSystem: r.resolve(FileSystem.self),
                contentExtractor: r.resolve(ContentExtractor.self),
                codesignExtractor: r.resolve(CodesignExtractor.self),
                configurationLoader: r.resolve(ConfigurationLoader.self),
                rules: r.resolve([TypedLintRule].self),
            )
        }
    }
}
