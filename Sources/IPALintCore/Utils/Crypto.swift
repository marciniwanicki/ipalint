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
import CommonCrypto
import Foundation
import TSCBasic

protocol Crypto {
    func sha256(at path: AbsolutePath) throws -> Data
    func sha256String(at path: AbsolutePath) throws -> String
}

final class DefaultCrypto: Crypto {
    func sha256(at path: AbsolutePath) throws -> Data {
        try SHA256Digest.file(at: path.asURL)
    }

    func sha256String(at path: AbsolutePath) throws -> String {
        try sha256(at: path).reduce(into: "") { acc, byte in acc.append(String(format: "%02x", byte)) }
    }
}

// https://inneka.com/programming/swift/sha256-in-swift/

private final class SHA256Digest {
    enum InputStreamError: Error {
        case createFailed(URL)
        case readFailed
    }

    private lazy var context: CC_SHA256_CTX = {
        var shaContext = CC_SHA256_CTX()
        CC_SHA256_Init(&shaContext)
        return shaContext
    }()

    init() {}

    static func file(at url: URL) throws -> Data {
        let sha256 = SHA256Digest()
        try sha256.update(url: url)
        return sha256.finalize()
    }

    private func update(url: URL) throws {
        guard let inputStream = InputStream(url: url) else {
            throw InputStreamError.createFailed(url)
        }
        return try update(inputStream: inputStream)
    }

    private func update(inputStream: InputStream) throws {
        inputStream.open()
        defer { inputStream.close() }

        let bufferSize = 4096
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while true {
            let bytesRead = inputStream.read(buffer, maxLength: bufferSize)
            if bytesRead < 0 {
                // Stream error occured
                throw (inputStream.streamError ?? InputStreamError.readFailed)
            } else if bytesRead == 0 {
                // EOF
                break
            }
            update(bytes: buffer, length: bytesRead)
        }
    }

    private func update(bytes: UnsafeRawPointer?, length: Int) {
        _ = CC_SHA256_Update(&context, bytes, CC_LONG(length))
    }

    private func finalize() -> Data {
        var resultBuffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&resultBuffer, &context)
        return Data(resultBuffer)
    }
}
