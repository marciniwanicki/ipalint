import Foundation

public protocol SnapshotResultRenderer {
    func render(result: SnapshotResult, to output: Output)
}

public final class TextSnapshotResultRenderer: SnapshotResultRenderer {
    public init() {}

    public func render(result: SnapshotResult, to output: Output) {
        output.write("Snapshot has been saved to '\(result.snapshotPath.pathString)'.\n")
    }
}
