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

        return Content(ipaPath: ipaPath, temporaryDirectory: temporaryDirectory)
    }
}
