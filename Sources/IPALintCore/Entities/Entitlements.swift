import Foundation

struct BundleIdentifier: Hashable {
    let rawValue: String
}

struct Entitlements {
    let dictionary: [String: Any]

    var applicationIdentifier: String? {
        string(from: "application-identifier")
    }

    var bundleIdentifier: BundleIdentifier? {
        guard let applicationIdentifier else {
            return nil
        }
        guard let firstDotIndex = applicationIdentifier.firstIndex(of: ".") else {
            return nil
        }

        return BundleIdentifier(rawValue: String(String(applicationIdentifier[firstDotIndex...]).dropFirst()))
    }

    var apsEnvironment: String? {
        string(from: "aps-environment")
    }

    var betaReportsActive: Bool? {
        bool(from: "beta-reports-active")
    }

    var associatedDomains: [String]? {
        array(from: "com.apple.developer.associated-domains")
    }

    var teamIdentifier: String? {
        string(from: "com.apple.developer.team-identifier")
    }

    var applicationGroups: [String]? {
        array(from: "com.apple.security.application-groups")
    }

    var getTaskAllow: Bool? {
        bool(from: "get-task-allow")
    }

    var keychainAccessGroups: [String]? {
        array(from: "keychain-access-groups")
    }

    // MARK: - Private

    private func string(from propertyName: String) -> String? {
        dictionary[propertyName] as? String
    }

    private func bool(from propertyName: String) -> Bool? {
        dictionary[propertyName] as? Bool
    }

    private func array(from propertyName: String) -> [String]? {
        dictionary[propertyName] as? [String]
    }
}
