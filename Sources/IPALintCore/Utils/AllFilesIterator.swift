//
//  FileSystemTreeIterator.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import TSCBasic

final class AllFilesIterator {
    private let fileSystemTree: FileSystemTree

    init(fileSystemTree: FileSystemTree) {
        self.fileSystemTree = fileSystemTree
    }

    func forEach(_ closure: (AbsolutePath) -> Void) {
        fileSystemTree.items.forEach { item in
            visit(item, parent: fileSystemTree.path, closure: closure)
        }
    }

    func all() -> [AbsolutePath] {
        var paths = [AbsolutePath]()
        fileSystemTree.items.forEach { item in
            visit(item, parent: fileSystemTree.path) {
                paths.append($0)
            }
        }
        return paths
    }

    // MARK: - Private

    private func visit(_ item: FileSystemTree.Item,
                       parent: AbsolutePath,
                       closure: (AbsolutePath) -> Void) {
        switch item {
        case let .file(file):
            let absolutePath = parent.appending(file.path)
            closure(absolutePath)
        case let .directory(dictionary):
            let childParent = parent.appending(dictionary.path)
            dictionary.items.forEach { child in
                visit(child, parent: childParent, closure: closure)
            }
        }
    }
}
