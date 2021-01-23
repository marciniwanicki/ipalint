import Foundation
import TSCBasic

protocol Archiver {
    func extract(source sourcePath: AbsolutePath,
                 destination destinationPath: AbsolutePath) throws
}

final class TarArchiver: Archiver {
    private let system: System

    init(system: System) {
        self.system = system
    }

    func extract(source sourcePath: AbsolutePath,
                 destination destinationPath: AbsolutePath) throws {
        let command = [
            "tar",
            "xvzf",
            sourcePath.pathString,
            "-C",
            destinationPath.pathString
        ]
        try system.execute(command, output: .muted)
    }
}
