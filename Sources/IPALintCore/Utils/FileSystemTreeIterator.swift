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

    }
}
