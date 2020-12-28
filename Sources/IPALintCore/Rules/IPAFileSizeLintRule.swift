//
//  PackageSizeLintRule.swift
//  ArgumentParser
//
//  Created by Marcin Iwanicki on 28/12/2020.
//

import Foundation
import TSCBasic

final class IPAFileSizeLintRule: FileLintRule {
    var configuration: LintRuleConfiguration = Configuration()
    let descriptor: LintRuleDescriptor = .init(
        identifier: .init(rawValue: "ipa_file_size"),
        name: "Package size",
        description: """
        This is some description
        """)

    private let fileSystem: FileSystem

    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    func lint(with ipaPath: AbsolutePath) throws -> LintRuleResult {
        print("Linting... \(ipaPath)")
        return .init(violations: [])
    }

    struct Configuration: LintRuleConfiguration {
        mutating func apply(configuration: Any) throws {
            print(configuration)
        }
    }
}
