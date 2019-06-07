import Foundation

open class ResponseContainer<T: Decodable>: Decodable {
    public var object: T?
    public var array: [T]?
    
    public init() {}
    
    public init(object: T) {
        self.object = object
    }
    
    public init(array: [T]) {
        self.array = array
    }
}
