//
//  DiffResultRenderer.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 27/12/2020.
//

import Foundation

public protocol DiffResultRenderer {
    func render(result: DiffResult, to output: Output)
}

public final class TextDiffResultRenderer: DiffResultRenderer {
    public init() {}

    public func render(result: DiffResult, to output: Output) {
        output.write(.stdout, String(describing: result))
    }
}
