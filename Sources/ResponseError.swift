import Foundation

public enum ResponseError: Error {
    case invalidResponse
    case statusFail(message: String?, code: String?)
    case networkConnection
    case httpError(statusCode: Int, message: String?)
    case invalidDate(string: String?)
}
