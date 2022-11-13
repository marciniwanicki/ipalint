import Foundation
import TSCBasic

public struct InfoContext {
    public let inputPath: String?
    public let tempPath: String?

    public init(inputPath: String?, tempPath: String?) {
        self.inputPath = inputPath
        self.tempPath = tempPath
    }
}

public struct InfoResult: Equatable {
    public let properties: [String: Property]
}

public protocol InfoInteractor {
    func info(with context: InfoContext) throws -> InfoResult
}

final class DefaultInfoInteractor: InfoInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let codesignExtractor: CodesignExtractor

    init(
        fileSystem: FileSystem,
        contentExtractor: ContentExtractor,
        codesignExtractor: CodesignExtractor
    ) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.codesignExtractor = codesignExtractor
    }

    func info(with context: InfoContext) throws -> InfoResult {
        let content = try contentExtractor.content(from: context)
        let allFilesIterator = try fileSystem.tree(at: content.temporaryDirectory.path).allFilesIterator()
        let entitlements = try codesignExtractor.entitlements(at: content.appPath)
        guard let entitlements else {
            throw CoreError.generic("Cannot read the entitlements -- PATH=\(content.appPath)")
        }
        let entitlementsDictionary = Dictionary(uniqueKeysWithValues: entitlements.properties.map {
            ("entitlements.\($0)", $1)
        })
        let generalDictionary: [String: Property] = [
            "general.ipa_path": .string(content.ipaPath.pathString),
            "general.ipa_size": .fileSize(try fileSystem.fileSize(at: content.ipaPath)),
            "general.payload_size": .fileSize(try fileSystem.directorySize(at: content.appPath)),
            "general.total_number_of_files": .int(allFilesIterator.all().count),
        ]
        let properties = entitlementsDictionary
            .merging(generalDictionary, uniquingKeysWith: { lhs, _ in lhs })
        return InfoResult(properties: properties)
    }
}

private extension String {
    static var empty: String {
        "<nil>"
    }
}
