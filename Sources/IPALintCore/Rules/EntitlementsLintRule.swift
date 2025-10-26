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

final class EntitlementsLintRule: ContentLintRule, ConfigurableLintRule {
    var configuration = EntitlementsLintRuleConfiguration()
    let descriptor = LintRuleDescriptor(
        identifier: .init(rawValue: "entitlements"),
        name: "Entitlements",
        description: """
        This is some description
        """
    )

    private let codesignExtractor: CodesignExtractor

    init(codesignExtractor: CodesignExtractor) {
        self.codesignExtractor = codesignExtractor
    }

    func lint(with content: Content) throws -> LintRuleResult {
        var violations: [LintRuleResult.Violation] = []
        let entitlements = try codesignExtractor.entitlements(at: content.appPath)
        if let content = configuration.setting(\.content), let values = content.value {
            try values.forEach { key, value in
                let presentValue = try EntitlementsLintRuleConfiguration.Value(entitlements.dictionary[key])
                if presentValue != value {
                    violations.append(
                        .init(
                            severity: content.severity,
                            message: "Invalid entitlements property value"
                                + " -- property=\(key), expected_value=\(value), present_value=\(presentValue)"
                        )
                    )
                }
            }
        }
        return result(violations: violations)
    }
}

struct EntitlementsLintRuleConfiguration: LintRuleConfiguration {
    enum Value: Codable, Equatable {
        case string(String)
        case array([String])

        init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self = try .string(container.decode(String.self))
            } catch {
                do {
                    let container = try decoder.singleValueContainer()
                    self = try .array(container.decode([String].self))
                } catch {
                    throw CoreError.generic("Cannot parse 'entitlements' rule configuration")
                }
            }
        }

        func encode(to _: Encoder) throws {
            // TODO:
        }

        init(_ anyValue: Any?) throws {
            if let string = anyValue as? String {
                self = .string(string)
            } else if let array = anyValue as? [String] {
                self = .array(array)
            } else {
                throw CoreError.generic("Cannot parse Entitlemenets value -- value=\(anyValue ?? "<nil>")")
            }
        }
    }

    struct Settings: Codable {
        var content: [String: Value]?
    }

    var enabled: Bool?
    var warning: Settings?
    var error: Settings?
}
