//
//  FileSize.swift
//  ArgumentParser
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public struct FileSize: Equatable, Codable, CustomStringConvertible {
    public let bytes: UInt64

    private static let KB: UInt64 = 1024
    private static let MB: UInt64 = 1024 * 1024
    private static let GB: UInt64 = 1024 * 1024 * 1024

    public var kilobytes: Float {
        return Float(bytes) / Float(FileSize.KB)
    }

    public var megabytes: Float {
        return  Float(bytes) / Float(FileSize.MB)
    }

    public var gigabytes: Float {
        return  Float(bytes) / Float(FileSize.GB)
    }

    public var bytesString: String {
        return String(format: "%ld B", bytes)
    }

    public var kilobytesString: String {
        return String(format: "%.2f KB", kilobytes)
    }

    public var metabytesString: String {
        return String(format: "%.2f MB", megabytes)
    }

    public var gigabytesString: String {
        return String(format: "%.2f GB", gigabytes)
    }

    public var description: String {
        guard bytes >= FileSize.KB else {
            return bytesString
        }
        guard bytes >= FileSize.MB else {
            return kilobytesString
        }
        guard bytes >= FileSize.GB else {
            return metabytesString
        }
        return gigabytesString
    }
}
