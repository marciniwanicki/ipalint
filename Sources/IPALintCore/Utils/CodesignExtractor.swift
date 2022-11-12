import Foundation
import TSCBasic

protocol CodesignExtractor {
    func entitlements(at appPath: AbsolutePath) throws -> Entitlements
}

final class DefaultCodesignExtractor: CodesignExtractor {
    private let system: System

    init(system: System) {
        self.system = system
    }

    func entitlements(at appPath: AbsolutePath) throws -> Entitlements {
        let command = ["xcrun", "codesign", "-d", "--entitlements", ":-", appPath.pathString]
        let output = CaptureOutput()
        try CoreError.rethrowCommand(
            { try system.execute(command, output: .custom(output)) },
            command: command,
            message: "Cannot read the .ipa file entitlements, the following command failed."
        )
        let data = output.stdoutString.data(using: .utf8)!
        guard let dictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            throw CoreError.generic("Cannot read the codesign entitlements")
        }
        return Entitlements(dictionary: dictionary)
    }
}
