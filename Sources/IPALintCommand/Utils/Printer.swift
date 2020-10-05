import Foundation

protocol Printer {
    func text(_ message: String)
    func error(_ message: String)
}

final class DefaultPrinter: Printer {
    func text(_ message: String) {
        print(message)
    }

    func error(_ message: String) {
        print("ERROR: \(message)")
    }
}
