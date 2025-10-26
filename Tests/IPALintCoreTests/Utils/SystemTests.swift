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

@Suite("System Tests")
struct SystemTests {
    private let subject = DefaultSystem()

    @Test("Execute successful command with default output")
    func executeSuccessfulCommand() throws {
        // When/Then - should not throw
        try subject.execute(["/bin/echo", "Hello"])
    }

    @Test("Execute successful command with muted output")
    func executeSuccessfulCommandMuted() throws {
        // When/Then - should not throw
        try subject.execute(["/bin/echo", "Hello"], output: .muted)
    }

    @Test("Execute successful command with custom output")
    func executeSuccessfulCommandCustomOutput() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When
        try subject.execute(["/bin/echo", "Hello"], output: .custom(captureOutput))

        // Then
        #expect(captureOutput.stdoutString.contains("Hello"))
    }

    @Test("Execute command captures stdout")
    func executeCapturesStdout() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When
        try subject.execute(["/bin/echo", "Test output"], output: .custom(captureOutput))

        // Then
        #expect(captureOutput.stdoutString.contains("Test output"))
        #expect(captureOutput.stderrString.isEmpty)
    }

    @Test("Execute command captures stderr")
    func executeCapturesStderr() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When - Use a shell command that writes to stderr
        try subject.execute(
            ["/bin/sh", "-c", "echo 'Error message' >&2"],
            output: .custom(captureOutput),
        )

        // Then
        #expect(captureOutput.stderrString.contains("Error message"))
    }

    @Test("Execute command with non-zero exit code throws error")
    func executeNonZeroExitCode() throws {
        // When/Then
        #expect(throws: SubprocessCoreError.self) {
            try subject.execute(["/bin/sh", "-c", "exit 1"])
        }
    }

    @Test("Execute command with specific exit code throws correct error")
    func executeSpecificExitCode() throws {
        // Given
        let exitCode: Int32 = 42

        // When
        var caughtError: SubprocessCoreError?
        do {
            try subject.execute(["/bin/sh", "-c", "exit \(exitCode)"])
        } catch let error as SubprocessCoreError {
            caughtError = error
        }

        // Then
        #expect(caughtError?.exitCode == exitCode)
    }

    @Test("Execute non-existent command throws error")
    func executeNonExistentCommand() throws {
        // When/Then
        #expect(throws: Error.self) {
            try subject.execute(["/bin/nonexistent-command-12345"])
        }
    }

    @Test("Execute command with multiple arguments")
    func executeMultipleArguments() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When
        try subject.execute(
            ["/bin/sh", "-c", "echo $1 $2", "-", "Hello", "World"],
            output: .custom(captureOutput),
        )

        // Then
        let output = captureOutput.stdoutString
        #expect(output.contains("Hello"))
        #expect(output.contains("World"))
    }

    @Test("Execute command without output parameter uses default")
    func executeWithoutOutputParameter() throws {
        // When/Then - should use default output and not throw
        try subject.execute(["/bin/echo", "Default output"])
    }

    @Test("Execute command with empty stdout produces empty capture")
    func executeEmptyStdout() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When - Command that produces no output
        try subject.execute(["/bin/sh", "-c", "exit 0"], output: .custom(captureOutput))

        // Then
        #expect(captureOutput.stdoutString.isEmpty || captureOutput.stdoutString
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("Execute command captures multiline output")
    func executeMultilineOutput() throws {
        // Given
        let captureOutput = CaptureOutput()

        // When
        try subject.execute(
            ["/bin/sh", "-c", "echo 'Line 1'; echo 'Line 2'; echo 'Line 3'"],
            output: .custom(captureOutput),
        )

        // Then
        let output = captureOutput.stdoutString
        #expect(output.contains("Line 1"))
        #expect(output.contains("Line 2"))
        #expect(output.contains("Line 3"))
    }

    @Test("Execute command with special characters in arguments")
    func executeSpecialCharacters() throws {
        // Given
        let captureOutput = CaptureOutput()
        let specialString = "Hello \"World\" with 'quotes' and $symbols"

        // When
        try subject.execute(
            ["/bin/echo", specialString],
            output: .custom(captureOutput),
        )

        // Then
        #expect(captureOutput.stdoutString.contains(specialString))
    }
}

@Suite("OutputType Tests")
struct OutputTypeTests {
    @Test("OutputType default returns StandardOutput")
    func outputTypeDefault() {
        // Given
        let outputType = OutputType.default

        // When
        let output = outputType.output

        // Then
        #expect(output === StandardOutput.shared)
    }

    @Test("OutputType muted returns ForwardOutput")
    func outputTypeMuted() {
        // Given
        let outputType = OutputType.muted

        // When
        let output = outputType.output

        // Then
        #expect(output is ForwardOutput)
    }

    @Test("OutputType custom returns provided output")
    func outputTypeCustom() {
        // Given
        let customOutput = CaptureOutput()
        let outputType = OutputType.custom(customOutput)

        // When
        let output = outputType.output

        // Then
        #expect(output === customOutput)
    }
}
