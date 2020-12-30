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
        guard fileSystem.exists(at: path) else {
            throw CoreError.generic("Config file at path '\(path.pathString)' does not exist")
        }

        let data = try CoreError.rethrow(try fileSystem.read(from: path),
                                         "Failed to read config file at path '\(path.pathString)'")
        guard let string = String(data: data, encoding: .utf8) else {
            throw CoreError.generic("Config file at path '\(path.pathString)' does not use UTF-8 encoding")
        }
        let rawConfiguration = try CoreError.rethrow(try Yams.load(yaml: string)) { description in
            .generic(
                """
                Config file at path '\(path.pathString)' cannot be parsed

                - \(description)
                """
            )
        }
        let bundleSpecific = self.bundleSpecific(from: rawConfiguration as Any)
        let all = self.all(from: rawConfiguration as Any)
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
