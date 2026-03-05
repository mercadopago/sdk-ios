// Inspired by:
// https://tools.ietf.org/html/rfc7231#section-4.3

/// Enum defining HTTP methods.
package enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}
