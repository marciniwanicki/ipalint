//
//  FileSize.swift
//  ArgumentParser
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public struct FileSize: Equatable, Codable {
    public let bytes: UInt64

    public var kilobytes: Float {
        return Float(bytes) / 1024
    }

    public var megabytes: Float {
        return kilobytes / 1024
    }

    public var metabytesString: String {
        return String(format: "%.2f MB", megabytes)
    }
}
