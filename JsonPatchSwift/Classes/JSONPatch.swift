import SwiftyJSON

/**
 Representation of a JSON Patch
 */
public struct JSONPatch {
    
    let operations: [JSONPatchOperation]
    
    /**
     Initializes a new `JSONPatch` based on a given SwiftyJSON representation.
     - Parameter _: A String representing one or many JSON Patch operations.
     e.g. (1) JSON({ "op": "add", "path": "/", "value": "foo" })
     or (> 1)
     JSON([ { "op": "add", "path": "/", "value": "foo" },
     { "op": "test", "path": "/", "value": "foo } ])
     - Throws: can throw any error from `JSONPatch.JPSJsonPatchInitialisationError` to
     notify failed initialization.
     - Returns: a `JSONPatch` representation of the given SwiftJSON object
     */
    public init(json: JSON) throws {
        
        // Check if there is an array of a dictionary as root element. Both are valid JSON patch documents.
        if json.type == .dictionary {
            self.operations = [try JSONPatch.extractOperationFromJson(json)]
            
        } else if json.type == .array {
            guard 0 < json.count else {
                throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.PatchWithEmptyError)
            }
            var operationArray = [JSONPatchOperation]()
            for i in 0..<json.count {
                let operation = json[i]
                operationArray.append(try JSONPatch.extractOperationFromJson(operation))
            }
            self.operations = operationArray
            
        } else {
            // All other types are not a valid JSON Patch Operation.
            throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.InvalidRootElement)
        }
    }
    
    /**
     Initializes a new `JSONPatch` based on a given String representation.
     - parameter _: A String representing one or many JSON Patch operations.
     e.g. (1) { "op": "add", "path": "/", "value": "foo" }
     or (> 1)
     [ { "op": "add", "path": "/", "value": "foo" },
     { "op": "test", "path": "/", "value": "foo } ]
     - throws: can throw any error from `JSONPatch.JPSJsonPatchInitialisationError` to notify failed initialization.
     - returns: a `JSONPatch` representation of the given JSON Patch String.
     */
    public init(jsonString: String) throws {
        let data = jsonString.data(using: .utf8)!
        let json: JSON
        do {
            json = try JSON(data: data, options: .allowFragments)
        } catch {
            throw JPSJsonPatchInitialisationError.InvalidJsonFormat(message: error.localizedDescription)
        }
        try self.init(json: json)
    }
    
    /// Possible errors thrown by the init function.
    public enum JPSJsonPatchInitialisationError: Error {
        /** InvalidJsonFormat: The given String is not a valid JSON. */
        case InvalidJsonFormat(message: String?)
        /** InvalidPatchFormat: The given Patch is invalid (e.g. missing mandatory parameters). See error message for details. */
        case InvalidPatchFormat(message: String?)
    }
}

extension JSONPatch: Equatable {
    
    public static func ==(lhs: JSONPatch, rhs: JSONPatch) -> Bool {
        guard lhs.operations.count == rhs.operations.count else { return false }
        for index in 0..<lhs.operations.count {
            if !(lhs.operations[index] == rhs.operations[index]) {
                return false
            }
        }
        return true
    }
}

// MARK: - Private functions
extension JSONPatch {
    
    private static func extractOperationFromJson(_ json: JSON) throws -> JSONPatchOperation {
        
        // The elements 'op' and 'path' are mandatory.
        guard let operation = json[JPSConstants.JsonPatch.Parameter.Op].string else {
            throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.OpElementNotFound)
        }
        guard let path = json[JPSConstants.JsonPatch.Parameter.Path].string else {
            throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.PathElementNotFound)
        }
        guard let operationType = JSONPatchOperation.OperationType(rawValue: operation) else {
            throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.InvalidOperation)
        }
        
        // 'from' element mandatory for .move, .copy operations
        var from: JSONPointer?
        if operationType == .move || operationType == .copy {
            guard let fromValue = json[JPSConstants.JsonPatch.Parameter.From].string else {
                throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.FromElementNotFound)
            }
            from = try JSONPointer(rawValue: fromValue)
        }
        
        // 'value' element mandatory for .add, .replace operations
        let value = json[JPSConstants.JsonPatch.Parameter.Value]
        // counterintuitive null check: https://github.com/SwiftyJSON/SwiftyJSON/issues/205
        if (operationType == .add || operationType == .replace) && value.null != nil {
            throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.ValueElementNotFound)
        }
        
        let pointer = try JSONPointer(rawValue: path)
        return JSONPatchOperation(type: operationType, pointer: pointer, value: value, from: from)
    }
    
}
