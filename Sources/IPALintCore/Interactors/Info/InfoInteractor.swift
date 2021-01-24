import Foundation
import TSCBasic

public struct InfoContext {
    public let ipaPath: String?
    public let tempPath: String?

    public init(ipaPath: String?, tempPath: String?) {
        self.ipaPath = ipaPath
        self.tempPath = tempPath
    }
}

public struct InfoResult: Equatable {
    public enum Value: Equatable, CustomStringConvertible {
        case fileSize(FileSize)
        case string(String)
        case uint(UInt)
        case int(Int)
        case array([String])

        public var description: String {
            switch self {
            case let .fileSize(value):
                return value.description
            case let .int(value):
                return value.description
            case let .string(value):
                return value
            case let .uint(value):
                return value.description
            case let .array(value):
                return value.description
            }
        }
    }

    public let properties: [String: Value]
}

public protocol InfoInteractor {
    func info(with context: InfoContext) throws -> InfoResult
}

final class DefaultInfoInteractor: InfoInteractor {
    private let fileSystem: FileSystem
    private let contentExtractor: ContentExtractor
    private let codesignExtractor: CodesignExtractor

    init(fileSystem: FileSystem,
         contentExtractor: ContentExtractor,
         codesignExtractor: CodesignExtractor) {
        self.fileSystem = fileSystem
        self.contentExtractor = contentExtractor
        self.codesignExtractor = codesignExtractor
    }

    func info(with context: InfoContext) throws -> InfoResult {
        let content = try contentExtractor.content(from: context)
        let allFilesIterator = try fileSystem.tree(at: content.temporaryDirectory.path).allFilesIterator()
        let entitlements = try codesignExtractor.entitlements(at: content.appPath)
        return InfoResult(properties: [
            "general.ipa_path": .string(content.ipaPath.pathString),
            "general.ipa_size": .fileSize(try fileSystem.fileSize(at: content.ipaPath)),
            "general.payload_size": .fileSize(try fileSystem.directorySize(at: content.appPath)),
            "general.total_number_of_files": .int(allFilesIterator.all().count),
            "entitlements.application_identifier": .string(entitlements.applicationIdentifier ?? .empty),
            "entitlements.bundle_identifier": .string(entitlements.bundleIdentifier?.rawValue ?? .empty),
            "entitlements.aps_environment": .string(entitlements.apsEnvironment ?? .empty),
            "entitlements.beta_reports_active": .string(entitlements.betaReportsActive
                .map { $0.description } ?? .empty),
            "entitlements.associated_domains": .array(entitlements.associatedDomains ?? []),
            "entitlements.team_identifier": .string(entitlements.teamIdentifier ?? .empty),
            "entitlements.application_groups": .array(entitlements.applicationGroups ?? []),
            "entitlements.get_task_allow": .string(entitlements.getTaskAllow.map { $0.description } ?? .empty),
            "entitlements.keychainAccessGroups": .array(entitlements.keychainAccessGroups ?? []),
        ])
    }
}

private extension String {
    static var empty: String {
        "<nil>"
    }
}
