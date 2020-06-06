//
//  IPAExplorer.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 06/06/2020.
//

import Foundation

public protocol Explorer {
    func scan(at path: String) -> Tree
}

final class IPAExplorer: Explorer {
    func scan(at path: String) -> Tree {
        return Tree(items: [])
    }
}
