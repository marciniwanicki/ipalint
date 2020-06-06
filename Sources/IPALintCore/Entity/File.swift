//
//  File.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 06/06/2020.
//

import Foundation

public protocol FileRepresentable {
    var file: File { get }
}

public struct File: Equatable {
    public struct Size: Equatable {
        private let numberOfBytes: UInt64
    }

    public let path: String
    public let size: Size
    public let sha256: String
}
