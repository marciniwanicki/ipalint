//
//  FileSystem+Extensions.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

protocol HasIPAPath {
    var ipaPath: String? { get }
}

protocol HasTempPath {
    var tempPath: String? { get }
}

extension InfoContext: HasIPAPath, HasTempPath {}
extension SnapshotContext: HasIPAPath, HasTempPath {}
extension LintContext: HasIPAPath, HasTempPath {}

extension FileSystem {
    func ipaFilePath(from context: HasIPAPath) throws -> AbsolutePath {
        if let ipaPath = context.ipaPath {
            return try absolutePath(from: ipaPath)
        }

        let items: [AbsolutePath] = try list(at: currentWorkingDirectory)
            .compactMap {
                if case let .file(file) = $0, file.path.extension == "ipa" {
                    return currentWorkingDirectory.appending(file.path)
                }
                return nil
            }

        guard !items.isEmpty else {
            throw CoreError.generic("Did find any .ipa files in the current directory.")
        }
        guard items.count == 1 else {
            throw CoreError.generic("Found more than one (\(items.count)) in the current directory.")
        }
        return items[0]
    }

    func tempDirectoryPath(from context: HasTempPath) throws -> AbsolutePath? {
        if let path = context.tempPath {
            return try absolutePath(from: path)
        }
        return nil
    }
}
