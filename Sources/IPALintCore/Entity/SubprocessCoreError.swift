import Foundation

public struct SubprocessCoreError: Error {
    public let exitCode: Int32

    init(exitCode: Int32) {
        self.exitCode = exitCode
    }
}
