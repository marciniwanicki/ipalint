//
//  SubprocessCoreError.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 25/12/2020.
//

import Foundation

public struct SubprocessCoreError: Error {
    public let exitCode: Int32

    init(exitCode: Int32) {
        self.exitCode = exitCode
    }
}
