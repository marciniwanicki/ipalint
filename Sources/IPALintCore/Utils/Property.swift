import Foundation

public enum Property: Equatable, Codable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case uint(UInt)
    case fileSize(FileSize)
    case dictionary([String: Property])
    case array([Property])

    init(dictionary: [String: Any]) throws {
        self = try .dictionary(Self.dictionary(from: dictionary))
    }

    static func dictionary(from dictionary: [String: Any]) throws -> [String: Property] {
        try dictionary.mapValues(value(from:))
    }

    // MARK: - CustomStringConvertable

    public var description: String {
        switch self {
        case let .string(string):
            return string
        case let .int(int):
            return int.description
        case let .uint(uint):
            return uint.description
        case let .fileSize(fileSize):
            return fileSize.description
        case let .dictionary(dictionary):
            return dictionary.description
        case let .array(array):
            return array.description
        }
    }

    // MARK: - Private

    private static func dictionary(from dictionary: [String: Any]) throws -> Property {
        try .dictionary(self.dictionary(from: dictionary))
    }

    private static func array(from array: [Any]) throws -> Property {
        try .array(array.map(value(from:)))
    }

    private static func value(from value: Any) throws -> Property {
        if let string = value as? String {
            return .string(string)
        }
        if let int = value as? Int {
            return .int(int)
        }
        if let array = value as? [Any] {
            return try self.array(from: array)
        }
        if let dictionary = value as? [String: Any] {
            return try self.dictionary(from: dictionary)
        }
        throw CoreError.generic("Failed to parse property -- VALUE=\(String(describing: value))")
    }
}
