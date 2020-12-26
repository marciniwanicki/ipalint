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
        case let .ipaSize(size):
            return keyValue(size.metabytesString)
        case let .string(_, value):
            return keyValue(value)
        case let .int(_, value):
            return keyValue("\(value)")
        case let .uint(_, value):
            return keyValue("\(value)")
        }
    }

    var key: String {
        switch self {
        case .ipaSize:
            return "ipa_size"
        case let .string(key, _):
            return key
        case let .int(key, _):
            return key
        case let .uint(key, _):
            return key
        }
    }

    private func keyValue(_ value: String) -> String {
        "\(key): \(value)"
    }
}
