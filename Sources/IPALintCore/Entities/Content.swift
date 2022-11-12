import Foundation
import TSCBasic

final class Content {
    let ipaPath: AbsolutePath
    let appPath: AbsolutePath
    let temporaryDirectory: Directory

    init(
        ipaPath: AbsolutePath,
        appPath: AbsolutePath,
        temporaryDirectory: Directory
    ) {
        self.ipaPath = ipaPath
        self.appPath = appPath
        self.temporaryDirectory = temporaryDirectory
    }

    var payloadPath: AbsolutePath {
        appPath.parentDirectory
    }
}
