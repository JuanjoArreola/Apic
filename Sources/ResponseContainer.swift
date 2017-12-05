import Foundation

open class ResponseContainer<T: Decodable>: Decodable {
    public var status: String?
    public var errorCode: String?
    public var errorMessage: String?
    
    public var object: T?
    public var array: [T]?
    
    public init() {}
    
    func successful() -> Bool {
        return status == "OK"
    }
    
    open func getError() -> Error? {
        if successful() { return nil }
        return ResponseError.statusFail(message: errorMessage, code: errorCode)
    }
}
