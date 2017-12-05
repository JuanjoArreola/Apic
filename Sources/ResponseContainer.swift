import Foundation

open class ResponseContainer<T: Decodable>: Decodable {
    public var status: String?
    
    public var object: T?
    public var array: [T]?
    
    public init() {}
    
    func successful() -> Bool {
        return status == "OK"
    }
}
