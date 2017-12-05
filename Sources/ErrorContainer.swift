import Foundation

public protocol ErrorContainerProtocol {
    func getError() -> Error?
}

open class ErrorContainer: Decodable, ErrorContainerProtocol {
    public var status: String?
    
    public var errorCode: String?
    public var errorMessage: String?
    
    var isSuccessful: Bool {
        return status == "OK"
    }
    
    open func getError() -> Error? {
        if isSuccessful { return nil }
        return ResponseError.statusFail(message: errorMessage, code: errorCode)
    }
}
