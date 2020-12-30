import Foundation

public protocol DiffResultRenderer {
    func render(result: DiffResult, to output: Output)
}

public final class TextDiffResultRenderer: DiffResultRenderer {
    public init() {}

    public func render(result: DiffResult, to output: Output) {
        result.diff.differences.forEach { diff in
            switch diff {
            case let .onlyInFirst(file):
                output.write("- \(file.path) (only in first)\n")
            case let .onlyInSecond(file):
                output.write("+ \(file.path) (only in second)\n")
            case let .difference(difference):
                output.write("* \(difference.path) (different content Δ \(difference.deltaFileSize))\n")
                output.write("  1) \(difference.firstSize) (\(difference.firstSha256))\n")
                output.write("  2) \(difference.secondSize) (\(difference.secondSha256))\n")
            }
        }
    }
}
