//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
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
