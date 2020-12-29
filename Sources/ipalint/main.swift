import Foundation
import IPALintCommand

func main() -> Int32 {
    CommandRunner().run(with: Array(ProcessInfo.processInfo.arguments.dropFirst()))
}

exit(main())
