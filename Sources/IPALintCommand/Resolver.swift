import Foundation

final class Resolver {
    var printer: Printer

    init() {
        printer = DefaultPrinter()
    }
}
