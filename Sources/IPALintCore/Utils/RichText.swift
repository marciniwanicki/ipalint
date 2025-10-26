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

public struct RichText: ExpressibleByStringLiteral {
    public enum Style: Sendable {
        case bold
        case dim
        case italic
        case underline
    }

    public enum Color: Sendable {
        case black
        case red
        case green
        case yellow
        case blue
        case lightGray
        case darkGray
        case white
    }

    public final class Attributes: Sendable {
        let style: Style?
        let color: Color?

        static let none = Attributes(
            style: nil,
            color: nil,
        )

        private init(
            style: Style?,
            color: Color?,
        ) {
            self.style = style
            self.color = color
        }

        static func style(_ style: Style) -> Attributes {
            Attributes(
                style: style,
                color: nil,
            )
        }

        static func color(_ color: Color) -> Attributes {
            Attributes(
                style: nil,
                color: color,
            )
        }

        static func + (lhs: Attributes, rhs: Attributes) -> Attributes {
            Attributes(
                style: rhs.style ?? lhs.style,
                color: rhs.color ?? lhs.color,
            )
        }
    }

    struct Token {
        let rawText: String
        let attributes: Attributes

        static func plain(_ string: String) -> Token {
            Token(rawText: string, attributes: .none)
        }
    }

    let tokens: [Token]

    // MARK: - Init

    public init(stringLiteral rawValue: String) {
        tokens = [.plain(rawValue)]
    }

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: - Public

    public func plainString() -> String {
        tokens.reduce(into: "") { acc, value in
            acc.append(value.rawText)
        }
    }

    public static var newLine: RichText {
        RichText(stringLiteral: "\n")
    }

    public static func text(_ string: String, _ attributes: Attributes) -> RichText {
        RichText(tokens: [.init(rawText: string, attributes: attributes)])
    }

    public static func + (lhs: RichText, rhs: RichText) -> RichText {
        RichText(tokens: lhs.tokens + rhs.tokens)
    }
}
