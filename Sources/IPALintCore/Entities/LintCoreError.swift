import Foundation

public enum CoreError: Error {
    case generic(String)

    static func rethrow<T>(_ closure: @autoclosure () throws -> T,
                           _ message: @autoclosure () -> String) throws -> T {
        try rethrow(closure(), .generic(message()))
    }

    static func rethrow<T>(_ closure: @autoclosure () throws -> T,
                           _ coreError: @autoclosure () -> CoreError) throws -> T {
        do {
            return try closure()
        } catch {
            throw coreError()
        }
    }

    static func rethrow<T>(_ closure: @autoclosure () throws -> T,
                           _ coreError: (String) -> CoreError) throws -> T {
        do {
            return try closure()
        } catch let error as LocalizedError {
            throw coreError(error.localizedDescription)
        } catch {
            throw coreError(String(describing: error))
        }
    }
}
