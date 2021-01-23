import Foundation
import TSCBasic

enum FileSystemItem {
    struct File {
        let path: RelativePath
    }

    struct Directory {
        let path: RelativePath
    }

    case file(File)
    case directory(Directory)
}

struct FileSystemTree {
    struct File {
        let path: RelativePath
    }

    struct Directory {
        let path: RelativePath
        let items: [Item]
    }

    enum Item {
        case file(File)
        case directory(Directory)
    }

    let path: AbsolutePath
    let items: [Item]
}

protocol FileSystem {
    var currentWorkingDirectory: AbsolutePath { get }

    func exists(at path: AbsolutePath) -> Bool

    func move(from fromPath: AbsolutePath, to toPath: AbsolutePath) throws

    func remove(at path: AbsolutePath) throws

    func list(at path: AbsolutePath) throws -> [FileSystemItem]

    func tree(at path: AbsolutePath) throws -> FileSystemTree

    func createDirectory(at path: AbsolutePath) throws

    func executable(at path: AbsolutePath) -> Bool

    func makeTemporaryDirectory() throws -> TemporaryDirectory

    func absolutePath(from string: String) throws -> AbsolutePath

    func fileSize(at path: AbsolutePath) throws -> FileSize

    func directorySize(at path: AbsolutePath) throws -> FileSize

    func temporaryDirectory(at existingPath: AbsolutePath?) throws -> Directory

    func write(data: Data, to path: AbsolutePath) throws

    func read(from path: AbsolutePath) throws -> Data
}

final class DefaultFileSystem: FileSystem {
    private let fileManager = FileManager.default

    var currentWorkingDirectory: AbsolutePath {
        return AbsolutePath(fileManager.currentDirectoryPath)
    }

    func exists(at path: AbsolutePath) -> Bool {
        return fileManager.fileExists(atPath: path.pathString)
    }

    func move(from fromPath: AbsolutePath, to toPath: AbsolutePath) throws {
        try fileManager.moveItem(at: fromPath.asURL, to: toPath.asURL)
    }

    func remove(at path: AbsolutePath) throws {
        try fileManager.removeItem(at: path.asURL)
    }

    func list(at path: AbsolutePath) throws -> [FileSystemItem] {
        try fileManager.contentsOfDirectory(atPath: path.pathString)
            .map { RelativePath($0) }
            .map {
                let absolutePath = path.appending($0)
                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: absolutePath.pathString, isDirectory: &isDir)
                if isDir.boolValue {
                    return .directory(FileSystemItem.Directory(path: $0))
                } else {
                    return .file(FileSystemItem.File(path: $0))
                }
            }
    }

    func tree(at path: AbsolutePath) throws -> FileSystemTree {
        FileSystemTree(path: path, items: try treeItems(at: path))
    }

    func createDirectory(at path: AbsolutePath) throws {
        try fileManager.createDirectory(at: path.asURL, withIntermediateDirectories: true)
    }

    func executable(at path: AbsolutePath) -> Bool {
        fileManager.isExecutableFile(atPath: path.pathString)
    }

    func makeTemporaryDirectory() throws -> TemporaryDirectory {
        return try TemporaryDirectory()
    }

    func absolutePath(from string: String) throws -> AbsolutePath {
        string.hasPrefix("/") ? AbsolutePath(string) : currentWorkingDirectory.appending(RelativePath(string))
    }

    func fileSize(at path: AbsolutePath) throws -> FileSize {
        let attributes = try fileManager.attributesOfItem(atPath: path.pathString)
        guard let size = attributes[FileAttributeKey.size] as? UInt64 else {
            throw CoreError.generic("Cannot calculate size of the file at path=\(path.pathString)")
        }
        return .init(bytes: size)
    }

    func directorySize(at path: AbsolutePath) throws -> FileSize {
        guard let enumerator = fileManager.enumerator(at: path.asURL, includingPropertiesForKeys: [.fileSizeKey]) else {
            throw CoreError.generic("Cannot enumerate files at path=\(path.pathString)")
        }

        return try .init(
            bytes: enumerator
                .compactMap { $0 as? URL }
                .compactMap { try $0.resourceValues(forKeys: [.fileSizeKey]).fileSize }
                .map { UInt64($0) }
                .reduce(UInt64(), +)
        )
    }

    func temporaryDirectory(at existingPath: AbsolutePath?) throws -> Directory {
        if let existingPath = existingPath {
            let items = try list(at: existingPath)
            guard items.isEmpty else {
                throw CoreError.generic("Temporary directory is not empty (path=\(existingPath.pathString))")
            }
            return PredefinedDirectory(path: existingPath)
        } else {
            return try makeTemporaryDirectory()
        }
    }

    func write(data: Data, to path: AbsolutePath) throws {
        try data.write(to: path.asURL)
    }

    func read(from path: AbsolutePath) throws -> Data {
        return try Data(contentsOf: path.asURL)
    }

    // MARK: - Private

    private func treeItems(at path: AbsolutePath) throws -> [FileSystemTree.Item] {
        try list(at: path).reduce(into: [FileSystemTree.Item]()) { acc, fileSystemItem in
            switch fileSystemItem {
            case let .file(file):
                acc.append(.file(.init(path: file.path)))
            case let .directory(directory):
                let absolutePath = path.appending(directory.path)
                let items = try treeItems(at: absolutePath)
                acc.append(.directory(.init(path: directory.path, items: items)))
            }
        }
    }
}
