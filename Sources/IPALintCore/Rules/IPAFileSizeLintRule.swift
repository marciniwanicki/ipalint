import Foundation
import TSCBasic

final class IPAFileSizeLintRule: FileLintRule, ConfigurableLintRule {
    var configuration = Configuration()
    let descriptor: LintRuleDescriptor = .init(
        identifier: .init(rawValue: "ipa_file_size"),
        name: "Package size",
        description: """
        This is some description
        """
    )

    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult {
        let fileSize = try fileSystem.fileSize(at: ipaPath)
        var violations: [LintRuleResult.Violation] = []
        if let minSize = configuration.warning.minSize, fileSize < minSize {
            violations.append(
                .warning(message: "The .ipa package size is smaller than min_size -- min_size=\(minSize), ipa_size=\(fileSize)")
            )
        }
        if let maxSize = configuration.warning.maxSize, fileSize > maxSize {
            violations.append(
                .warning(message: "The .ipa package size is bigger than max_size -- max_size=\(maxSize), ipa_size=\(fileSize)")
            )
        }
        if let minSize = configuration.error.minSize, fileSize < minSize {
            violations.append(
                .error(message: "The .ipa package size is smaller than min_size -- min_size=\(minSize), ipa_size=\(fileSize)")
            )
        }
        if let maxSize = configuration.error.maxSize, fileSize > maxSize {
            violations.append(
                .error(message: "The .ipa package size is bigger than max_size -- max_size=\(maxSize), ipa_size=\(fileSize)")
            )
        }
        return .init(rule: descriptor, violations: violations)
    }

    struct Configuration: LintRuleConfiguration {
        struct Warning {
            var minSize: FileSize?
            var maxSize: FileSize?
        }

        struct Error {
            var minSize: FileSize?
            var maxSize: FileSize?
        }

        var warning = Warning()
        var error = Error()

        mutating func apply(configuration: Any) throws {
            guard let dictionary = configuration as? [String: Any] else {
                return
            }

            if let warningDictionary = dictionary["warning"] as? [String: Any] {
                warning.minSize = fileSize(from: warningDictionary["min_size"])
                warning.maxSize = fileSize(from: warningDictionary["max_size"])
            }
            if let errorDictionary = dictionary["error"] as? [String: Any] {
                error.minSize = fileSize(from: errorDictionary["min_size"])
                error.maxSize = fileSize(from: errorDictionary["max_size"])
            }
        }

        private func fileSize(from anyObject: Any?) -> FileSize? {
            if let value = anyObject as? UInt64 {
                return FileSize(bytes: value)
            }
            if let value = anyObject as? String {
                return FileSize(string: value)
            }
            return nil
        }
    }
}
