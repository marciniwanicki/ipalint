//
//  Content.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 28/12/2020.
//

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
