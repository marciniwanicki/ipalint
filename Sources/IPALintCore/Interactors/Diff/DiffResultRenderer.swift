import Foundation

public protocol DiffResultRenderer {
    func render(result: DiffResult)
}

public final class TextDiffResultRenderer: DiffResultRenderer {
    private let output: RichTextOutput

    public init(output: RichTextOutput) {
        self.output = output
    }

    public func render(result: DiffResult) {
        for diff in result.diff.differences {
            switch diff {
            case let .onlyInFirst(file):
                output.write(
                    .text("- \(file.path) \(file.size)", .color(.red)) + .text(" (only in first)\n", .color(.darkGray))
                )
            case let .onlyInSecond(file):
                output.write(
                    .text("+ \(file.path) \(file.size)", .color(.green)) +
                        .text(" (only in second)\n", .color(.darkGray))
                )
            case let .difference(difference):
                output.write(
                    .text("* \(difference.path) (different content Δ \(difference.deltaFileSize))\n", .color(.yellow))
                        + .text("  1) \(difference.firstSize) (\(difference.firstSha256))\n", .color(.yellow))
                        + .text("  2) \(difference.secondSize) (\(difference.secondSha256))\n", .color(.yellow))
                )
            }
        }
    }
}
