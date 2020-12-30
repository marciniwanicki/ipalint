import Darwin
import Foundation

public enum OutputStream {
    case stdout
    case stderr
}

public protocol Output: AnyObject {
    func write(_ string: String, to stream: OutputStream)

    var redirected: Bool { get }
}

extension Output {
    func write(_ string: String) {
        write(string, to: .stdout)
    }

    func write(_ data: Data, to stream: OutputStream) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }
        write(string, to: stream)
    }

    func write(_ bytes: [UInt8], to stream: OutputStream) {
        write(Data(bytes), to: stream)
    }
}

public final class StandardOutput: Output {
    private init() {}

    public static let shared = StandardOutput()

    private let lock = NSLock()

    public func write(_ string: String, to stream: OutputStream) {
        lock.lock(); defer { lock.unlock() }
        switch stream {
        case .stdout:
            fputs(string, stdout)
            fflush(stdout)
        case .stderr:
            fputs(string, stderr)
            fflush(stderr)
        }
    }

    public var redirected: Bool {
        isatty(fileno(stdout)) != 1
    }
}

final class ForwardOutput: Output {
    let redirected = false

    private let forwardStdout: ((String) -> Void)?
    private let forwardStderr: ((String) -> Void)?

    init(stdout: ((String) -> Void)?, stderr: ((String) -> Void)?) {
        forwardStdout = stdout
        forwardStderr = stderr
    }

    public func write(_ string: String, to stream: OutputStream) {
        switch stream {
        case .stdout:
            forwardStdout?(string)
        case .stderr:
            forwardStderr?(string)
        }
    }
}

final class CaptureOutput: Output {
    let redirected = false

    private(set) var captured: [(OutputStream, String)] = []

    var stdout: [String] { captured.filter { $0.0 == .stdout }.map { $0.1 } }
    var stderr: [String] { captured.filter { $0.0 == .stderr }.map { $0.1 } }
    var output: [String] { captured.map { $0.1 } }

    public func write(_ string: String, to stream: OutputStream) {
        switch stream {
        case .stdout:
            captured.append((.stdout, string))
        case .stderr:
            captured.append((.stderr, string))
        }
    }
}
