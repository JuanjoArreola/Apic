import Foundation

public enum ResponseError: Error {
    case invalidResponse(string: String?)
    case statusFail(message: String?, code: String?)
    case networkConnection
    case httpError(statusCode: Int, message: String?)
    case invalidDate(string: String?)
    case emptyResponse
    
    public var localizedDescription: String {
        switch self {
        case .invalidResponse(_):
            return "The response data could not be decoded"
        case .httpError(let statusCode, let message):
            switch statusCode {
            case 404:
                return "404: Not found"
            default:
                return "HTTP Error (\(statusCode): \(message ?? "")"
            }
        default:
            return self.localizedDescription
        }
    }
}
