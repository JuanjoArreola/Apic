//
//  CustomErrorResponseParser.swift
//  Apic
//
//  Created by Juan Jose Arreola on 8/16/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

open class AbstractErrorModel: AbstractModel, Error { }

open class CustomErrorResponseParser<StatusType: Equatable, ErrorModelType: AbstractErrorModel>: DefaultResponseParser<StatusType> {
    
    open var errorKey: String?
    
    override public func dictionary(fromJSON JSON: Any?) throws -> [String: Any] {
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
            var modelError: Any?
            do {
                modelError = try ErrorModelType(dictionary: errorDictionary)
            } catch {
                Log.error("Error parsing error dictionary")
            }
            if let error = modelError as? Error {
                throw error
            }
        }
        let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
        let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
        throw RepositoryError.statusFail(message: message, code: code)
    }
}
