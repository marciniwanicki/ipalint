//
//  FileSystem.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 23/12/2020.
//

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
