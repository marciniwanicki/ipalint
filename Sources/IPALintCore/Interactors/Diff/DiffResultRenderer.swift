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
        result.diff.differences.forEach { diff in
            switch diff {
            case let .onlyInFirst(file):
                output.write(
                    .text("- \(file.path)", .color(.red)) + .text(" (only in first)\n", .color(.darkGray))
                )
            case let .onlyInSecond(file):
                output.write(
                    .text("+ \(file.path)", .color(.green)) + .text(" (only in second)\n", .color(.darkGray))
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
