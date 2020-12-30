import Foundation

public protocol InfoResultRenderer {
    func render(result: InfoResult, to output: Output)
}

public final class TextInfoResultRenderer: InfoResultRenderer {
    public init() {}

    public func render(result: InfoResult, to output: Output) {
        result.properties.keys.sorted().forEach { key in
            let value = result.properties[key]?.description ?? "<nil>"
            output.write("\(key): \(value)\n")
        }
    }
}
