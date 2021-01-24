import Foundation

//final class FileExtensionsLintRule: FileSystemTreeLintRule, ConfigurableLintRule {
//    var configuration = FileExtensionsLintRuleConfiguration()
//    let descriptor: LintRuleDescriptor = .init(
//        identifier: .init(rawValue: "ipa_file_size"),
//        name: "Package size",
//        description: """
//        This is some description
//        """
//    )
//
//    func lint(with fileSystemTree: FileSystemTree) throws -> LintRuleResult {
//        return .init(rule: descriptor, violations: [])
//    }
//}
//
//struct FileExtensionsLintRuleConfiguration: LintRuleConfiguration {
//    typealias Settings = 
//    var enabled: Bool?
//}
