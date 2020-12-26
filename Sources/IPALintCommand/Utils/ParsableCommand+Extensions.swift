//
//  ParsableCommand+Extensions.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation
import ArgumentParser

extension ParsableCommand {
    var r: Resolver { Resolver() }
}
