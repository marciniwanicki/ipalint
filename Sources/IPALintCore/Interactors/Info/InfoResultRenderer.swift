import Foundation

public protocol InfoResultRenderer {
    func render(result: InfoResult)
}

public final class TextInfoResultRenderer: InfoResultRenderer {
    private let output: RichTextOutput

    public init(output: RichTextOutput) {
        self.output = output
    }

    public func render(result: InfoResult) {
        for key in result.properties.keys.sorted() {
            let value = result.properties[key]?.description ?? "<nil>"
            output.write(
                .text("· \(key) =", .color(.lightGray))
                    + .text(" \(value)", .color(.white))
                    + .newLine
            )
        }
    }
}
