//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
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
        closure: (AbsolutePath) -> Void,
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
