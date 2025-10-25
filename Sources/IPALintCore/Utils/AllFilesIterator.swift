import Foundation
import TSCBasic

final class AllFilesIterator {
    private let fileSystemTree: FileSystemTree

    init(fileSystemTree: FileSystemTree) {
        self.fileSystemTree = fileSystemTree
    }

    func forEach(_ closure: (AbsolutePath) -> Void) {
        for item in fileSystemTree.items {
            visit(item, parent: fileSystemTree.path, closure: closure)
        }
    }

    func all() -> [AbsolutePath] {
        var paths = [AbsolutePath]()
        for item in fileSystemTree.items {
            visit(item, parent: fileSystemTree.path) {
                paths.append($0)
            }
        }
        return paths
    }

    // MARK: - Private

    private func visit(
        _ item: FileSystemTree.Item,
        parent: AbsolutePath,
        closure: (AbsolutePath) -> Void
    ) {
        switch item {
        case let .file(file):
            let absolutePath = parent.appending(file.path)
            closure(absolutePath)
        case let .directory(dictionary):
            let childParent = parent.appending(dictionary.path)
            for child in dictionary.items {
                visit(child, parent: childParent, closure: closure)
            }
        }
    }
}

extension FileSystemTree {
    func allFilesIterator() -> AllFilesIterator {
        AllFilesIterator(fileSystemTree: self)
    }
}
