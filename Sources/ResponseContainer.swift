import Foundation

open class ResponseContainer<T: Decodable>: Decodable {
    public var object: T?
    public var array: [T]?
    
    public init() {}
}
