//
//  InfoResultRenderer.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public protocol InfoResultRenderer {
    func render(result: InfoResult, to output: Output)
}

public final class TextInfoResultRenderer: InfoResultRenderer {
    public init() {}

    public func render(result: InfoResult, to output: Output) {
        result.properties.keys.sorted().forEach { key in
            let value = result.properties[key]?.description ?? "<nil>"
            output.write(.stdout, "\(key): \(value)\n")
        }
    }
}
