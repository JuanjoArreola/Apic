import Foundation

open class ResponseContainer<T: Codable>: Codable {
    var status: String?
    var errorCode: String?
    var errorMessage: String?
    
    var object: T?
    var array: [T]?
    var dictionary: [String: T]?
    
    func successful() -> Bool {
        return status == "OK"
    }
    
    func getError() -> Error? {
        if successful() { return nil }
        return ResponseError.statusFail(message: errorMessage, code: errorCode)
    }
}
