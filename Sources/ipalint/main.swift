import Foundation
import IPALintCommand

func main() -> Int32 {
    let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
    let commandRunner = CommandRunner()
    let code = commandRunner.run(with: arguments)
    return code
}

exit(main())
