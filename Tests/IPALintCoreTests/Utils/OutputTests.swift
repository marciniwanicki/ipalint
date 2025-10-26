//
// Copyright 2020-2025 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import Testing

@testable import IPALintCore

@Suite("CaptureOutput Tests")
struct CaptureOutputTests {
    private let subject = CaptureOutput()

    @Test("Captures stdout")
    func captureStdout() {
        // When
        subject.write("Hello stdout", to: .stdout)

        // Then
        #expect(subject.stdout == ["Hello stdout"])
        #expect(subject.stderr == [])
    }

    @Test("Captures stderr")
    func captureStderr() {
        // When
        subject.write("Hello stderr", to: .stderr)

        // Then
        #expect(subject.stderr == ["Hello stderr"])
        #expect(subject.stdout == [])
    }

    @Test("Captures both stdout and stderr")
    func captureBoth() {
        // When
        subject.write("First stdout", to: .stdout)
        subject.write("First stderr", to: .stderr)
        subject.write("Second stdout", to: .stdout)

        // Then
        #expect(subject.stdout == ["First stdout", "Second stdout"])
        #expect(subject.stderr == ["First stderr"])
        #expect(subject.output == ["First stdout", "First stderr", "Second stdout"])
    }

    @Test("StdoutString joins with newlines")
    func stdoutString() {
        // Given
        subject.write("Line 1", to: .stdout)
        subject.write("Line 2", to: .stdout)

        // When
        let result = subject.stdoutString

        // Then
        #expect(result == "Line 1\nLine 2")
    }

    @Test("StderrString joins with newlines")
    func stderrString() {
        // Given
        subject.write("Error 1", to: .stderr)
        subject.write("Error 2", to: .stderr)

        // When
        let result = subject.stderrString

        // Then
        #expect(result == "Error 1\nError 2")
    }

    @Test("OutputString joins all output with newlines")
    func outputString() {
        // Given
        subject.write("stdout line", to: .stdout)
        subject.write("stderr line", to: .stderr)

        // When
        let result = subject.outputString

        // Then
        #expect(result == "stdout line\nstderr line")
    }

    @Test("Clear removes all captured output")
    func clear() {
        // Given
        subject.write("Some output", to: .stdout)
        subject.write("Some error", to: .stderr)

        // When
        subject.clear()

        // Then
        #expect(subject.stdout == [])
        #expect(subject.stderr == [])
        #expect(subject.output == [])
    }

    @Test("Redirected is always true")
    func redirected() {
        // Then
        #expect(subject.redirected == true)
    }

    @Test("Writes Data to stdout")
    func writeDataToStdout() {
        // Given
        let data = "Data content".data(using: .utf8)!

        // When
        subject.write(data, to: .stdout)

        // Then
        #expect(subject.stdout == ["Data content"])
    }

    @Test("Writes Data to stderr")
    func writeDataToStderr() {
        // Given
        let data = "Error data".data(using: .utf8)!

        // When
        subject.write(data, to: .stderr)

        // Then
        #expect(subject.stderr == ["Error data"])
    }

    @Test("Writes byte array to stdout")
    func writeByteArrayToStdout() {
        // Given
        let bytes: [UInt8] = [72, 101, 108, 108, 111] // "Hello"

        // When
        subject.write(bytes, to: .stdout)

        // Then
        #expect(subject.stdout == ["Hello"])
    }

    @Test("Writes byte array to stderr")
    func writeByteArrayToStderr() {
        // Given
        let bytes: [UInt8] = [69, 114, 114, 111, 114] // "Error"

        // When
        subject.write(bytes, to: .stderr)

        // Then
        #expect(subject.stderr == ["Error"])
    }

    @Test("Write without stream parameter defaults to stdout")
    func writeDefaultsToStdout() {
        // When
        subject.write("Default output")

        // Then
        #expect(subject.stdout == ["Default output"])
        #expect(subject.stderr == [])
    }
}

@Suite("ForwardOutput Tests")
struct ForwardOutputTests {
    @Test("Forwards to stdout closure")
    func forwardStdout() {
        // Given
        var capturedStdout: [String] = []
        let subject = ForwardOutput(
            stdout: { capturedStdout.append($0) },
            stderr: nil
        )

        // When
        subject.write("Test output", to: .stdout)

        // Then
        #expect(capturedStdout == ["Test output"])
    }

    @Test("Forwards to stderr closure")
    func forwardStderr() {
        // Given
        var capturedStderr: [String] = []
        let subject = ForwardOutput(
            stdout: nil,
            stderr: { capturedStderr.append($0) }
        )

        // When
        subject.write("Test error", to: .stderr)

        // Then
        #expect(capturedStderr == ["Test error"])
    }

    @Test("Forwards to both closures")
    func forwardBoth() {
        // Given
        var capturedStdout: [String] = []
        var capturedStderr: [String] = []
        let subject = ForwardOutput(
            stdout: { capturedStdout.append($0) },
            stderr: { capturedStderr.append($0) }
        )

        // When
        subject.write("Output", to: .stdout)
        subject.write("Error", to: .stderr)

        // Then
        #expect(capturedStdout == ["Output"])
        #expect(capturedStderr == ["Error"])
    }

    @Test("Does nothing when closure is nil")
    func nilClosure() {
        // Given
        let subject = ForwardOutput(stdout: nil, stderr: nil)

        // When/Then - should not crash
        subject.write("Test", to: .stdout)
        subject.write("Test", to: .stderr)
    }

    @Test("Redirected is always false")
    func redirected() {
        // Given
        let subject = ForwardOutput(stdout: nil, stderr: nil)

        // Then
        #expect(subject.redirected == false)
    }
}

@Suite("CombinedOutput Tests")
struct CombinedOutputTests {
    @Test("Writes to all outputs")
    func writeToAll() {
        // Given
        let capture1 = CaptureOutput()
        let capture2 = CaptureOutput()
        let subject = CombinedOutput(outputs: [capture1, capture2])

        // When
        subject.write("Test output", to: .stdout)

        // Then
        #expect(capture1.stdout == ["Test output"])
        #expect(capture2.stdout == ["Test output"])
    }

    @Test("Writes to different streams")
    func writeToDifferentStreams() {
        // Given
        let capture1 = CaptureOutput()
        let capture2 = CaptureOutput()
        let subject = CombinedOutput(outputs: [capture1, capture2])

        // When
        subject.write("Stdout message", to: .stdout)
        subject.write("Stderr message", to: .stderr)

        // Then
        #expect(capture1.stdout == ["Stdout message"])
        #expect(capture1.stderr == ["Stderr message"])
        #expect(capture2.stdout == ["Stdout message"])
        #expect(capture2.stderr == ["Stderr message"])
    }

    @Test("Redirected is true when any output is redirected")
    func redirectedWhenAnyRedirected() {
        // Given
        let capture = CaptureOutput() // redirected = true
        let forward = ForwardOutput(stdout: nil, stderr: nil) // redirected = false
        let subject = CombinedOutput(outputs: [capture, forward])

        // Then
        #expect(subject.redirected == true)
    }

    @Test("Redirected is false when no outputs are redirected")
    func redirectedWhenNoneRedirected() {
        // Given
        let forward1 = ForwardOutput(stdout: nil, stderr: nil)
        let forward2 = ForwardOutput(stdout: nil, stderr: nil)
        let subject = CombinedOutput(outputs: [forward1, forward2])

        // Then
        #expect(subject.redirected == false)
    }

    @Test("Handles empty outputs array")
    func emptyOutputs() {
        // Given
        let subject = CombinedOutput(outputs: [])

        // When/Then - should not crash
        subject.write("Test", to: .stdout)
        #expect(subject.redirected == false)
    }

    @Test("Works with single output")
    func singleOutput() {
        // Given
        let capture = CaptureOutput()
        let subject = CombinedOutput(outputs: [capture])

        // When
        subject.write("Test", to: .stdout)

        // Then
        #expect(capture.stdout == ["Test"])
    }
}
