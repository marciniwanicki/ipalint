//
//  Output.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Darwin
import Foundation

public enum OutputStream {
    case stdout
    case stderr
}

public protocol Output: AnyObject {
    func write(_ stream: OutputStream, _ string: String)
}

extension Output {
    func write(_ stream: OutputStream, _ data: Data) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }
        write(stream, string)
    }

    func write(_ stream: OutputStream, _ bytes: [UInt8]) {
        write(stream, Data(bytes))
    }
}

public final class StandardOutput: Output {
    private init() {}

    public static let shared = StandardOutput()

    private let lock = NSLock()

    public func write(_ stream: OutputStream, _ string: String) {
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
}

final class ForwardOutput: Output {
    private let forwardStdout: ((String) -> Void)?
    private let forwardStderr: ((String) -> Void)?

    init(stdout: ((String) -> Void)?, stderr: ((String) -> Void)?) {
        forwardStdout = stdout
        forwardStderr = stderr
    }

    func write(_ stream: OutputStream, _ string: String) {
        switch stream {
        case .stdout:
            forwardStdout?(string)
        case .stderr:
            forwardStderr?(string)
        }
    }
}

final class CaptureOutput: Output {
    private(set) var captured: [(OutputStream, String)] = []

    var stdout: [String] { captured.filter { $0.0 == .stdout }.map { $0.1 } }
    var stderr: [String] { captured.filter { $0.0 == .stderr }.map { $0.1 } }
    var output: [String] { captured.map { $0.1 } }

    func write(_ stream: OutputStream, _ string: String) {
        switch stream {
        case .stdout:
            captured.append((.stdout, string))
        case .stderr:
            captured.append((.stderr, string))
        }
    }
}
