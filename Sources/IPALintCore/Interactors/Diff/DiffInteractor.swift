import Foundation
import TSCBasic

public struct DiffContext {
    let path1: String
    let path2: String

    public init(
        path1: String,
        path2: String
    ) {
        self.path1 = path1
        self.path2 = path2
    }
}

public struct DiffResult {
    let diff: SnapshotDiff
}

public protocol DiffInteractor {
    func diff(with context: DiffContext) throws -> DiffResult
}

final class DefaultDiffInteractor: DiffInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let snapshotGenerator: SnapshotGenerator
    private let snapshotParser: SnapshotParser

    init(
        fileSystem: FileSystem,
        contentExtractor: ContentExtractor,
        snapshotGenerator: SnapshotGenerator,
        snapshotParser: SnapshotParser
    ) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.snapshotGenerator = snapshotGenerator
        self.snapshotParser = snapshotParser
    }

    func diff(with context: DiffContext) throws -> DiffResult {
        let snapshot1 = try snapshot(at: context.path1)
        let snapshot2 = try snapshot(at: context.path2)
        let filesMap1 = snapshot1.filesMap()
        let filesMap2 = snapshot2.filesMap()
        let paths1 = Set(filesMap1.keys)
        let paths2 = Set(filesMap2.keys)
        let pathsOnlyInFirst = paths1.subtracting(paths2)
        let pathsOnlyInSecond = paths2.subtracting(paths1)
        let commonPaths = paths1.intersection(paths2)
        let onlyInFirstFiles: [SnapshotDiff.FileDiff] = pathsOnlyInFirst.map { path in
            .onlyInFirst(filesMap1[path]!)
        }
        let onlyInSecondFiles: [SnapshotDiff.FileDiff] = pathsOnlyInSecond.map { path in
            .onlyInSecond(filesMap2[path]!)
        }
        let differentFiles: [SnapshotDiff.FileDiff] = commonPaths.compactMap { path in
            let firstFile = filesMap1[path]!
            let secondFile = filesMap2[path]!
            guard firstFile.sha256 != secondFile.sha256 else {
                return nil
            }

            return .difference(.init(
                path: path,
                firstSha256: firstFile.sha256,
                firstSize: firstFile.size,
                secondSha256: secondFile.sha256,
                secondSize: secondFile.size
            ))
        }

        return DiffResult(diff: .init(differences: onlyInFirstFiles + onlyInSecondFiles + differentFiles))
    }

    // MARK: - Private

    private func snapshot(at path: String) throws -> Snapshot { // .ipalint-temp directory?
        let snapshotContext = SnapshotContext(ipaPath: path, tempPath: nil, outputPath: nil)
        let content = try contentExtractor.content(from: snapshotContext)
        return try snapshotGenerator.snapshot(of: content)
    }
}

private extension Snapshot {
    func filesMap() -> [RelativePath: Snapshot.File] {
        files.reduce(into: [RelativePath: Snapshot.File]()) { acc, file in
            acc[file.path] = file
        }
    }
}
