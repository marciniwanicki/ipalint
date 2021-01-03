import Foundation

public struct FileSize: Equatable, Codable, CustomStringConvertible, Comparable {
    public let bytes: UInt64

    enum Unit {
        case B
        case KB
        case MB
        case GB
    }

    private static let KB: UInt64 = 1024
    private static let MB: UInt64 = 1024 * 1024
    private static let GB: UInt64 = 1024 * 1024 * 1024

    // MARK: - Init

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let value = FileSize(string: try container.decode(String.self)) else {
            throw CoreError.generic("Cannot decode FileSize")
        }
        self = value
    }

    public init(bytes: UInt64) {
        self.bytes = bytes
    }

    public init?(string: String) {
        let components = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard components.count == 2 else {
            return nil
        }
        guard let unit = FileSize.unit(from: components[1]) else {
            return nil
        }
        let value = components[0]
        if let valueUInt64 = UInt64(value) {
            self = FileSize(bytes: valueUInt64 * unit)
        } else if let valueDouble = Double(value) {
            self = FileSize(bytes: UInt64(valueDouble * Double(unit)))
        } else {
            return nil
        }
    }

    // MARK: - Public

    public func delta(_ rhs: FileSize) -> DeltaFileSize {
        if rhs.bytes > bytes {
            return .greater(.init(bytes: rhs.bytes - bytes))
        }
        if rhs.bytes < bytes {
            return .lower(.init(bytes: bytes - rhs.bytes))
        }
        return .equal
    }

    // MARK: - CustomStringConvertable

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

    // MARK: - Comparable

    public static func < (lhs: FileSize, rhs: FileSize) -> Bool {
        lhs.bytes < rhs.bytes
    }

    // MARK: - Private

    private var kilobytes: Float {
        return Float(bytes) / Float(FileSize.KB)
    }

    private var megabytes: Float {
        return Float(bytes) / Float(FileSize.MB)
    }

    private var gigabytes: Float {
        return Float(bytes) / Float(FileSize.GB)
    }

    private var bytesString: String {
        return String(format: "%ld B", bytes)
    }

    private var kilobytesString: String {
        return String(format: "%.2f KB", kilobytes)
    }

    private var metabytesString: String {
        return String(format: "%.2f MB", megabytes)
    }

    private var gigabytesString: String {
        return String(format: "%.2f GB", gigabytes)
    }

    private static func unit(from string: String) -> UInt64? {
        switch string {
        case "B":
            return 1
        case "KB":
            return KB
        case "MB":
            return MB
        case "GB":
            return GB
        default:
            return nil
        }
    }
}

public enum DeltaFileSize: Equatable, CustomStringConvertible {
    case lower(FileSize)
    case greater(FileSize)
    case equal

    public var description: String {
        switch self {
        case let .lower(fileSize):
            return "-\(fileSize.description)"
        case let .greater(fileSize):
            return "+\(fileSize.description)"
        case .equal:
            return "0"
        }
    }
}
