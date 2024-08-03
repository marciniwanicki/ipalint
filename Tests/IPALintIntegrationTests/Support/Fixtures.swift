import Foundation
import TSCBasic

enum Fixture: Equatable {
    case valid_ipa_1
}

final class Fixtures {
    private let fileManager = FileManager.default
    private let namespace = "ipalint_fixtures"
    private let identifier = UUID()

    func setUp() throws {
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    func tearDown() throws {
        try fileManager.removeItem(at: rootURL)
    }

    func prepare(fixture: Fixture) -> AbsolutePath {
        fatalError()
    }

    // MARK: - Private

    private var rootURL: URL {
        fileManager.temporaryDirectory
            .appending(component: namespace)
            .appending(component: identifier.uuidString)
    }
}
