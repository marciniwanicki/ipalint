//
//  ConfigurationLoder.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 28/12/2020.
//

import Foundation
import TSCBasic
import Yams

protocol ConfigurationLoader {
    func load(from path: AbsolutePath) throws -> Configuration
}

/*
 // .ipalint.yml

 com.bloomber.app.development:
  rules:
    - first_rule
      - blas: v32

 all:
 rules:
   my_rules:
     - whatever we want

 */
final class Configuration {
    class BundleConfiguration {
        let rules: [String: Any]

        static let empty = BundleConfiguration(rules: [:])

        init(rules: [String: Any]) {
            self.rules = rules
        }
    }

    let bundleSpecific: [String: BundleConfiguration]
    let all: BundleConfiguration

    init(bundleSpecific: [String: BundleConfiguration],
         all: BundleConfiguration) {
        self.bundleSpecific = bundleSpecific
        self.all = all
    }
}

final class YamlConfigurationLoader: ConfigurationLoader {
    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func load(from path: AbsolutePath) throws -> Configuration {
        let data = try fileSystem.read(from: path)
        let string = String(data: data, encoding: .utf8)!
        let rawConfiguration = try Yams.load(yaml: string)!
        let bundleSpecific = self.bundleSpecific(from: rawConfiguration)
        let all = self.all(from: rawConfiguration)
        return .init(bundleSpecific: bundleSpecific, all: all)
    }

    // TODO: Replace by storng type i.e. BundleIdentifier
    private func bundleSpecific(from rawConfiguration: Any) -> [String: Configuration.BundleConfiguration] {
        guard let dictionary = rawConfiguration as? [String: Any] else {
            return [:]
        }
        return dictionary.mapValues { all(from: $0) }
    }

    private func all(from rawConfiguration: Any) -> Configuration.BundleConfiguration {
        guard let dictionary = rawConfiguration as? [String: Any] else {
            return .empty
        }
        guard let all = dictionary["all"] as? [String: Any] else {
            return .empty
        }

        let rules: [String: Any] = all["rules"] as? [String: Any] ?? [:]

        return .init(rules: rules)
    }
}
