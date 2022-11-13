import Foundation

struct BundleIdentifier: Hashable {
    let rawValue: String
}

struct Entitlements: Equatable {
    let properties: [String: Property]

    var bundleIdentifier: BundleIdentifier? {
        guard case let .string(applicationIdentifier) = properties["application-identifier"] else {
            return nil
        }
        guard let firstDotIndex = applicationIdentifier.firstIndex(of: ".") else {
            return nil
        }

        return BundleIdentifier(rawValue: String(String(applicationIdentifier[firstDotIndex...]).dropFirst()))
    }
}
