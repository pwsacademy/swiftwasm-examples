import Foundation

print("The command was executed with the following arguments:")
print(ProcessInfo.processInfo.arguments.joined(separator: " "))

if ProcessInfo.processInfo.environment.count > 0 {
    print("and environment variables:")
    for (key, value) in ProcessInfo.processInfo.environment {
        print("\(key): \(value)")
    }
} else {
    print("and no environment variables.")
}
