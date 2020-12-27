//
//  DiffInteractor.swift
//  ArgumentParser
//
//  Created by Marcin Iwanicki on 26/12/2020.
//

import Foundation

public struct DiffContext {

}

public struct DiffResult {

}

public protocol DiffInteractor {
    func diff(with context: DiffContext) throws -> DiffResult
}

final class DefaultDiffInteractor: DiffInteractor {

    func diff(with context: DiffContext) throws -> DiffResult {
        return DiffResult()
    }

    // MARK: - Private
}
