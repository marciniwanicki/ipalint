//
//  Linter.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

public struct LinterResult {

}

protocol Linter {
    func lint(with context: LinterContext) throws -> LinterResult
}
