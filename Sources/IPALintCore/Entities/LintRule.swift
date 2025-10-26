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

struct LintRuleResult {
    enum ViolationSeverity: String {
        case warning
        case error
    }

    struct Violation {
        let severity: ViolationSeverity
        let message: String

        static func warning(message: String) -> Violation {
            .init(severity: .warning, message: message)
        }

        static func error(message: String) -> Violation {
            .init(severity: .error, message: message)
        }
    }

    let rule: LintRuleDescriptor
    let violations: [Violation]
}

struct LintRuleIdentifier: RawRepresentable, Hashable {
    let rawValue: String
}

struct LintRuleDescriptor: Equatable {
    let identifier: LintRuleIdentifier
    let name: String
    let description: String
}

protocol LintRuleConfigurationModifier {
    func isEnabled() -> Bool

    mutating func apply(configuration: Any) throws
}

protocol LintRuleConfiguration: Codable {
    associatedtype Settings: Codable

    var enabled: Bool? { get set }

    var warning: Settings? { get set }
    var error: Settings? { get set }
}

struct LintRuleConfigurationSetting<T> {
    var value: T?
    var severity: LintRuleResult.ViolationSeverity
}

extension LintRuleConfiguration {
    func isEnabled() -> Bool {
        enabled ?? true
    }

    func setting<T>(_ keyPath: KeyPath<Settings, T?>) -> LintRuleConfigurationSetting<T>? {
        if let error {
            if let value = error[keyPath: keyPath] {
                return .init(value: value, severity: .error)
            }
        }
        if let warning {
            return .init(value: warning[keyPath: keyPath], severity: .warning)
        }
        return nil
    }
}

protocol LintRule {
    var descriptor: LintRuleDescriptor { get }
}

protocol ConfigurableLintRule: LintRuleConfigurationModifier {
    associatedtype Configuration: LintRuleConfiguration

    var configuration: Configuration { get set }
}

extension ConfigurableLintRule {
    func isEnabled() -> Bool {
        configuration.isEnabled()
    }
}

extension LintRule {
    func result(violations: [LintRuleResult.Violation]) -> LintRuleResult {
        .init(rule: descriptor, violations: violations)
    }
}

extension LintRule where Self: ConfigurableLintRule {
    mutating func apply(configuration: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: configuration, options: .fragmentsAllowed)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.configuration = try decoder.decode(Configuration.self, from: data)
    }
}

protocol FileLintRule: LintRule {
    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult
}

protocol ContentLintRule: LintRule {
    func lint(with content: Content) throws -> LintRuleResult
}

protocol FileSystemTreeLintRule: LintRule {
    func lint(with fileSystemTree: FileSystemTree) throws -> LintRuleResult
}

enum TypedLintRule {
    case file(FileLintRule)
    case content(ContentLintRule)
    case fileSystemTree(FileSystemTreeLintRule)

    var lintRule: LintRule {
        switch self {
        case let .file(rule):
            rule
        case let .content(rule):
            rule
        case let .fileSystemTree(rule):
            rule
        }
    }

    var descriptor: LintRuleDescriptor {
        lintRule.descriptor
    }

    func isEnabled() -> Bool {
        if let configurableRule = lintRule as? LintRuleConfigurationModifier {
            return configurableRule.isEnabled()
        }
        return true
    }

    func apply(configuration: Any?) throws {
        guard let configuration else {
            return
        }
        if var configurableRule = lintRule as? LintRuleConfigurationModifier {
            try configurableRule.apply(configuration: configuration)
        }
    }
}
