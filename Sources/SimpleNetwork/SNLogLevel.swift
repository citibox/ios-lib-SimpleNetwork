import Foundation

/// Controls the verbosity of log output from the SimpleNetwork library.
public enum SNLogLevel: Int, Comparable {
    /// No logging.
    case none = 0
    /// Errors and retries only.
    case error = 1
    /// Errors and request/response summaries.
    case info = 2
    /// Full verbose output including headers and body.
    case debug = 3

    public static func < (lhs: SNLogLevel, rhs: SNLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
