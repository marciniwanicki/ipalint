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
import Testing
import TSCBasic

@testable import IPALintCore

@Suite("EntitlementsLintRule Tests")
struct EntitlementsLintRuleTests {
    @Test("Rule has correct descriptor")
    func ruleDescriptor() {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)

        // When/Then
        #expect(subject.descriptor.identifier.rawValue == "entitlements")
        #expect(subject.descriptor.name == "Entitlements")
        #expect(!subject.descriptor.description.isEmpty)
    }

    @Test("No violations when no configuration")
    func noViolationsWithoutConfiguration() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [:])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("No violations when entitlements match expected string value")
    func noViolationsWithMatchingStringValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.app-sandbox": "true",
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.app-sandbox": .string("true"),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when entitlement string value does not match")
    func violationWithNonMatchingStringValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.app-sandbox": "false",
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.app-sandbox": .string("true"),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Invalid entitlements property value"))
        #expect(result.violations[0].message.contains("com.apple.security.app-sandbox"))
        #expect(result.violations[0].message.contains("expected_value=string(\"true\")"))
        #expect(result.violations[0].message.contains("present_value=string(\"false\")"))
    }

    @Test("No violations when entitlements match expected array value")
    func noViolationsWithMatchingArrayValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.files.absolute-path": ["/tmp", "/usr/local"],
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.files.absolute-path": .array(["/tmp", "/usr/local"]),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when entitlement array value does not match")
    func violationWithNonMatchingArrayValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.files.absolute-path": ["/tmp"],
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.files.absolute-path": .array(["/tmp", "/usr/local"]),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Invalid entitlements property value"))
    }

    @Test("No violations when entitlements match expected int value")
    func noViolationsWithMatchingIntValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.max-connections": 10,
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.max-connections": .int(10),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.isEmpty)
    }

    @Test("Violation when entitlement int value does not match")
    func violationWithNonMatchingIntValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.max-connections": 5,
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.max-connections": .int(10),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
        #expect(result.violations[0].message.contains("Invalid entitlements property value"))
        #expect(result.violations[0].message.contains("com.apple.security.max-connections"))
        #expect(result.violations[0].message.contains("expected_value=int(10)"))
        #expect(result.violations[0].message.contains("present_value=int(5)"))
    }

    @Test("Throws error when entitlement is missing")
    func throwsErrorWithMissingEntitlement() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [:])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.app-sandbox": .string("true"),
        ])
        let content = try makeContent()

        // When/Then
        do {
            _ = try subject.lint(with: content)
            Issue.record("Expected error to be thrown")
        } catch let error as CoreError {
            let errorMessage = "\(error)"
            #expect(errorMessage.contains("Cannot parse Entitlemenets value"))
            #expect(errorMessage.contains("<nil>"))
        } catch {
            Issue.record("Expected CoreError but got \(error)")
        }
    }

    @Test("Throws error with unsupported entitlement value type")
    func throwsErrorWithUnsupportedValueType() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.double-value": 42.5,
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.double-value": .string("42.5"),
        ])
        let content = try makeContent()

        // When/Then
        do {
            _ = try subject.lint(with: content)
            Issue.record("Expected error to be thrown")
        } catch let error as CoreError {
            let errorMessage = "\(error)"
            #expect(errorMessage.contains("Cannot parse Entitlemenets value"))
            #expect(errorMessage.contains("42.5"))
        } catch {
            Issue.record("Expected CoreError but got \(error)")
        }
    }

    @Test("Throws error with boolean entitlement value")
    func throwsErrorWithBooleanValue() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.flag": true,
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.flag": .string("true"),
        ])
        let content = try makeContent()

        // When/Then
        do {
            _ = try subject.lint(with: content)
            Issue.record("Expected error to be thrown")
        } catch let error as CoreError {
            let errorMessage = "\(error)"
            #expect(errorMessage.contains("Cannot parse Entitlemenets value"))
            #expect(errorMessage.contains("true"))
        } catch {
            Issue.record("Expected CoreError but got \(error)")
        }
    }

    @Test("Warning severity when configured as warning")
    func warningSeverity() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.app-sandbox": "false",
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.warning = .init(content: [
            "com.apple.security.app-sandbox": .string("true"),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .warning)
    }

    @Test("Multiple violations for multiple mismatches")
    func multipleViolations() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "com.apple.security.app-sandbox": "false",
            "com.apple.security.network.client": "false",
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.error = .init(content: [
            "com.apple.security.app-sandbox": .string("true"),
            "com.apple.security.network.client": .string("true"),
        ])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 2)
        #expect(result.violations.allSatisfy { $0.severity == .error })
    }

    @Test("Error configuration takes precedence over warning")
    func errorTakesPrecedenceOverWarning() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [
            "key1": "wrong",
        ])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        subject.configuration.warning = .init(content: ["key1": .string("correct")])
        subject.configuration.error = .init(content: ["key1": .string("correct")])
        let content = try makeContent()

        // When
        let result = try subject.lint(with: content)

        // Then
        #expect(result.violations.count == 1)
        #expect(result.violations[0].severity == .error)
    }

    @Test("Codesign extractor is called with correct path")
    func codesignExtractorCalledWithCorrectPath() throws {
        // Given
        let codesignExtractor = MockCodesignExtractor()
        codesignExtractor.entitlementsToReturn = Entitlements(dictionary: [:])
        let subject = EntitlementsLintRule(codesignExtractor: codesignExtractor)
        let content = try makeContent()

        // When
        _ = try subject.lint(with: content)

        // Then
        #expect(codesignExtractor.lastAppPath == content.appPath)
    }

    // MARK: - Private

    private func makeContent() throws -> Content {
        try Content(
            ipaPath: AbsolutePath(validating: "/tmp/test.ipa"),
            appPath: AbsolutePath(validating: "/tmp/test.app"),
            temporaryDirectory: PredefinedDirectory(path: AbsolutePath(validating: "/tmp")),
        )
    }
}

// MARK: - Mock

private final class MockCodesignExtractor: CodesignExtractor {
    var entitlementsToReturn = Entitlements(dictionary: [:])
    var lastAppPath: AbsolutePath?

    func entitlements(at appPath: AbsolutePath) throws -> Entitlements {
        lastAppPath = appPath
        return entitlementsToReturn
    }
}
