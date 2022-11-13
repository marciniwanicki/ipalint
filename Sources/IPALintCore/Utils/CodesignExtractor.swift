import Foundation
import TSCBasic

protocol CodesignExtractor {
    func entitlements(at path: AbsolutePath) throws -> Entitlements?
}

final class DefaultCodesignExtractor: CodesignExtractor {
    private let system: System

    init(system: System) {
        self.system = system
    }

    func entitlements(at path: AbsolutePath) throws -> Entitlements? {
        let command = ["xcrun", "codesign", "-d", "--xml", "--entitlements", "-", path.pathString]
        let output = CaptureOutput()
        do {
            try system.execute(command, output: .custom(output))
        } catch {
            return nil
        }
        let data = output.stdoutString.data(using: .utf8)!
        guard let dictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            throw CoreError.generic("Cannot read the codesign entitlements -- PATH=\(path)")
        }

        return Entitlements(properties: try Property.dictionary(from: dictionary))
    }
}
