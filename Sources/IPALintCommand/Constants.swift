import ArgumentParser
import Foundation
import TSCBasic
import TSCUtility

final class Constants {
    static let version: Version = {
        let identifiers = [
            debugVersionIdentifier(),
            gitHashVersionIdentifier(),
        ].compactMap { $0 }
        return Version(0, 1, 0, buildMetadataIdentifiers: identifiers)
    }()

    private static let gitHash = "#GIT_SHORT_HASH#"

    // MARK: - Init

    private init() {}

    // MARK: - Private

    private static func debugVersionIdentifier() -> String? {
        debug ? "debug" : nil
    }

    private static func gitHashVersionIdentifier() -> String? {
        !gitHash.hasPrefix("#") ? gitHash : "local"
    }

    private static var debug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}

enum Help {
    enum Option {
        static var bundlePath: ArgumentHelp { "Path to bundle file (.ipa, .app)." }
        static var bundlePath1: ArgumentHelp { "Path to first bundle file (.ipa, .app)." }
        static var bundlePath2: ArgumentHelp { "Path to second bundle file (.ipa, .app)." }
    }
}
