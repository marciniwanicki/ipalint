//
//  Output.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

enum OutputStream {
    case stdout
    case stderr
}

protocol Output: AnyObject {
    func write(_ stream: OutputStream, _ string: String)

    func write(_ stream: OutputStream, _ data: Data)

    func write(_ stream: OutputStream, _ bytes: [UInt8])
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

final class StandardOutput: Output {
    private init() {}

    static let shared = StandardOutput()

    func write(_ stream: OutputStream, _ string: String) {
        // Should never be called
    }
}

final class ForwardOutput: Output {
    private let forwardStdout: ((String) -> Void)?
    private let forwardStderr: ((String) -> Void)?

    init(stdout: ((String) -> Void)?, stderr: ((String) -> Void)?) {
        self.forwardStdout = stdout
        self.forwardStderr = stderr
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

