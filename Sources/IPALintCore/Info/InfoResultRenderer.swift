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
        result.properties.forEach { property in
            output.write(.stdout, "\(property.description)\n")
        }
    }
}

private extension InfoResult.Property {
    var description: String {
        switch self {
        case let .ipaPath(path):
            return keyValue(path.pathString)
        case let .ipaSize(size):
            return keyValue(size.metabytesString)
        }
    }

    var key: String {
        switch self {
        case .ipaPath:
            return "ipa_path"
        case .ipaSize:
            return "ipa_size"
        }
    }

    private func keyValue(_ value: String) -> String {
        "\(key): \(value)"
    }
}
