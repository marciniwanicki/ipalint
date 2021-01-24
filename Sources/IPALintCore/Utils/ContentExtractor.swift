import Foundation
import TSCBasic

protocol ContentExtractor {
    func content(from context: HasIPAPath & HasTempPath) throws -> Content
}

final class DefaultContentExtractor: ContentExtractor {
    private let system: System
    private let fileSystem: FileSystem
    private let archiver: Archiver

    init(system: System, fileSystem: FileSystem, archiver: Archiver) {
        self.system = system
        self.fileSystem = fileSystem
        self.archiver = archiver
    }

    func content(from context: HasIPAPath & HasTempPath) throws -> Content {
        let ipaPath = try fileSystem.ipaFilePath(from: context)
        let tempDirOptionalPath = try context.tempPath.map { try fileSystem.absolutePath(from: $0) }
        let temporaryDirectory = try fileSystem.temporaryDirectory(at: tempDirOptionalPath)

        try archiver.extract(source: ipaPath, destination: temporaryDirectory.path)

        let appPath = try self.appPath(in: temporaryDirectory)
        return Content(ipaPath: ipaPath,
                       appPath: appPath,
                       temporaryDirectory: temporaryDirectory)
    }

    // MARK: - Private

    private func appPath(in temporaryDirectory: Directory) throws -> AbsolutePath {
        let payloadPath = temporaryDirectory.path.appending(component: "Payload")
        let appPaths: [AbsolutePath] = try fileSystem.list(at: payloadPath)
            .compactMap {
                if case let .directory(directory) = $0 {
                    return payloadPath.appending(directory.path)
                }
                return nil
            }
            .filter { $0.extension == "app" }
        guard let appPath = appPaths.first else {
            throw CoreError.generic("Payload does not contain any .app bundles")
        }
        guard appPaths.count == 1 else {
            throw CoreError.generic("Payload contains multiple .app bundles (\(appPaths.count))")
        }
        return appPath
    }
}
