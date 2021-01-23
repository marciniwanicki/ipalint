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
        guard let applicationIdentifier = applicationIdentifier else {
            return nil
        }
        guard let firstDotIndex = applicationIdentifier.firstIndex(of: ".") else {
            return nil
        }

        return BundleIdentifier(rawValue: String(String(applicationIdentifier[firstDotIndex...]).dropFirst()))
    }

    // MARK: - Private

    private func string(from propertyName: String) -> String? {
        guard let string = dictionary[propertyName] as? String else {
            return nil
        }
        return string
    }
}
