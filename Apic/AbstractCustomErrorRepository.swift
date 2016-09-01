//
//  AbstractCustomErrorRepository.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 8/16/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

open class AbstractErrorModel: AbstractModel, Error { }

open class AbstractCustomErrorRepository<StatusType: Equatable, ErrorModelType: AbstractErrorModel>: AbstractRepository<StatusType> {
    open var errorKey: String?
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusOk: StatusType? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil, errorKey: String? = nil) {
        super.init(objectKey: objectKey, objectsKey: objectsKey, statusKey: statusKey, statusOk: statusOk, errorDescriptionKey: errorDescriptionKey, errorCodeKey: errorCodeKey)
        self.errorKey = errorKey
    }
    
    override func dictionary(fromJSON JSON: Any?) throws -> [String: Any] {
        guard let data = JSON as? [String: Any] else {
            throw RepositoryError.badJSONContent
        }
        guard let statusKey = statusKey, let statusOk = statusOk else {
            return data
        }
        guard let status = data[statusKey] as? StatusType else {
            throw RepositoryError.badJSONContent
        }
        if status == statusOk {
            return data
        }
        if let errorDictionary = errorKey != nil ? data[errorKey!] as? [String: Any] : nil {
            var modelError: ErrorModelType?
            do {
                modelError = try ErrorModelType(dictionary: errorDictionary)
            } catch {
                Log.error("Error parsing error dictionary")
            }
            if let error = modelError {
                throw error
            }
        }
        let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
        let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
        throw RepositoryError.statusFail(message: message, code: code)
    }
}
