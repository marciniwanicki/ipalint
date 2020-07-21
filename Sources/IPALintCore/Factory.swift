//
//  Factory.swift
//  IPALintCore
//
//  Created by Marcin Iwanicki on 06/06/2020.
//

import Foundation

public final class Factory {
    func makeExplorar() -> Explorer {
        return IPAExplorer()
    }
}
