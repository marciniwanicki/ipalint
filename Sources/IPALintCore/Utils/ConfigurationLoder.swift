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
import TSCBasic
import Yams

protocol ConfigurationLoader {
    func load(from path: AbsolutePath) throws -> Configuration
}

// .ipalint.yml
//
// bundles:
//   com.bloomberg.blabla:
//     rules:
//       ipa_file_size:
//         warning:
//           min_size: 23 MB
//             max_size: 43 MB
//
//   all:
//     rules:
//       ipa_file_size:
//         warning:
//           min_size: 23 MB
//           max_size: 43 MB
//         error:
//           min_size: 30 MB
//           max_size: 31 MB

final class Configuration {
    class BundleConfiguration {
        let rules: [String: Any]

        static let empty = BundleConfiguration(rules: [:])

        init(rules: [String: Any]) {
            self.rules = rules
        }
    }

    let bundles: [BundleIdentifier: BundleConfiguration]

    var all: BundleConfiguration? {
        bundles[BundleIdentifier(rawValue: "all")]
    }

    init(bundles: [BundleIdentifier: BundleConfiguration]) {
        self.bundles = bundles
    }

    func ruleConfiguration(bundleIdentifier: BundleIdentifier, typedLintRule: TypedLintRule) -> Any? {
        let lintRoleIdentifier = typedLintRule.lintRule.descriptor.identifier.rawValue
        if let bundleSpecificConfiguration = bundles[bundleIdentifier],
           let lintRoleConfiguration = bundleSpecificConfiguration.rules[lintRoleIdentifier] {
            return lintRoleConfiguration
        }
        return all?.rules[lintRoleIdentifier]
    }

    func ruleIdentifiers(bundleIdentifier: BundleIdentifier) -> [LintRuleIdentifier] {
        let bundleRuleKeys = bundles[bundleIdentifier]?.rules.keys.map { String($0) } ?? []
        let allRuleKeys = all?.rules.keys.map { String($0) } ?? []
        return (bundleRuleKeys + allRuleKeys)
            .unique()
            .sorted()
            .map { LintRuleIdentifier(rawValue: $0) }
    }
}

final class YamlConfigurationLoader: ConfigurationLoader {
    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func load(from path: AbsolutePath) throws -> Configuration {
        guard fileSystem.exists(at: path) else {
            throw CoreError.generic("Config file at path '\(path.pathString)' does not exist")
        }

        let data = try CoreError.rethrow(
            fileSystem.read(from: path),
            "Failed to read config file at path '\(path.pathString)'"
        )
        guard let string = String(data: data, encoding: .utf8) else {
            throw CoreError.generic("Config file at path '\(path.pathString)' does not use UTF-8 encoding")
        }
        let rawConfiguration = try CoreError.rethrow(Yams.load(yaml: string)) { description in
            .generic(
                """
                Config file at path '\(path.pathString)' cannot be parsed

                - \(description)
                """
            )
        }
        return .init(bundles: bundles(from: rawConfiguration as Any))
    }

    private func bundles(from rawConfiguration: Any) -> [BundleIdentifier: Configuration.BundleConfiguration] {
        guard let dictionary = rawConfiguration as? [String: Any] else {
            return [:]
        }
        guard let bundles = dictionary["bundles"] as? [String: Any?] else {
            return [:]
        }

        let tuples = bundles.map { (BundleIdentifier(rawValue: $0), configuration(from: $1)) }
        return Dictionary(tuples, uniquingKeysWith: { lhs, _ in lhs })
    }

    private func configuration(from rawConfiguration: Any?) -> Configuration.BundleConfiguration {
        guard let dictionary = rawConfiguration as? [String: Any] else {
            return .empty
        }
        let rules: [String: Any] = dictionary["rules"] as? [String: Any] ?? [:]
        return .init(rules: rules)
    }
}
