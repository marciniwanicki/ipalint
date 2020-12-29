import Foundation
import TSCBasic

final class Content {
    let ipaPath: AbsolutePath
    let temporaryDirectory: Directory

    init(ipaPath: AbsolutePath, temporaryDirectory: Directory) {
        self.ipaPath = ipaPath
        self.temporaryDirectory = temporaryDirectory
    }
}
