//
//  AbstractCustomErrorRepository.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 8/16/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

public class AbstractErrorModel: AbstractModel, ErrorType { }

public class AbstractCustomErrorRepository<StatusType: Equatable, ErrorModelType: AbstractErrorModel>: AbstractRepository<StatusType> {
    public var errorKey: String?
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusOk: StatusType? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil, errorKey: String? = nil) {
        super.init(objectKey: objectKey, objectsKey: objectsKey, statusKey: statusKey, statusOk: statusOk, errorDescriptionKey: errorDescriptionKey, errorCodeKey: errorCodeKey)
        self.errorKey = errorKey
    }
    
    override func dictionaryFromJSON(JSON: AnyObject?) throws -> [String: AnyObject] {
        guard let data = JSON as? [String: AnyObject] else {
            throw RepositoryError.BadJSONContent
        }
        guard let statusKey = statusKey, statusOk = statusOk else {
            return data
        }
        guard let status = data[statusKey] as? StatusType else {
            throw RepositoryError.BadJSONContent
        }
        if status == statusOk {
            return data
        }
        if let errorDictionary = errorKey != nil ? data[errorKey!] as? [String: AnyObject] : nil {
            throw try ErrorModelType(dictionary: errorDictionary)
        }
        let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
        let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
        throw RepositoryError.StatusFail(message: message, code: code)
    }
}