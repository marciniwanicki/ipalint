import Foundation
import TSCBasic

protocol HasInputPath {
    var inputPath: String? { get }
}

protocol HasTempPath {
    var tempPath: String? { get }
}

extension InfoContext: HasInputPath, HasTempPath {}
extension SnapshotContext: HasInputPath, HasTempPath {}
extension LintContext: HasInputPath, HasTempPath {}

extension FileSystem {
    func ipaFilePath(from context: HasInputPath) throws -> AbsolutePath {
        if let ipaPath = context.inputPath {
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
