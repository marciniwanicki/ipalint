//
//  Linter.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

public struct LintContext {

}

public struct LintResult {

}

public protocol LintInteractor {
    func lint(with context: LintContext) throws -> LintResult
}

final class DefaultLintInteractor: LintInteractor {
    func lint(with context: LintContext) throws -> LintResult {
        return LintResult()
    }

    // MARK: - Private
}
