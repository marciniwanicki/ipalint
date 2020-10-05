import Foundation

final class Resolver {
    static let shared: Resolver = .init()

    let printer: Printer

    private init() {
        printer = DefaultPrinter()
    }
}
