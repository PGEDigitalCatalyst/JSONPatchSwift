
import SwiftyJSON

public struct JSONPatch {
    
    public let operations: [JSONPatchOperation]
    
    public init(json: JSON) throws {
        switch json.type {
        case .dictionary:
            operations = [try JSONPatch.extractOperation(from: json)]
        case .array:
            guard !json.isEmpty else { throw JSONPatchError.emptyPatchArray }
            operations = try json.array!.map({ try JSONPatch.extractOperation(from: $0) })
        default:
            throw JSONPatchError.invalidRootElement
        }
    }
    
    public init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else { throw JSONPatchError.badStringEncoding }
        let json = try JSON(data: data, options: .allowFragments)
        try self.init(json: json)
    }
    
    public enum JSONPatchError: Error {
        case emptyPatchArray
        case invalidRootElement
        case badStringEncoding
        case missingOperationElement
        case missingPathElement
        case invalidOperation
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
    
    private static func extractOperation(from json: JSON) throws -> JSONPatchOperation {
        
        // The elements 'op' and 'path' are mandatory.
        guard let operation = json[JPSConstants.JsonPatch.Parameter.Op].string else {
            throw JSONPatchError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.OpElementNotFound)
        }
        guard let path = json[JPSConstants.JsonPatch.Parameter.Path].string else {
            throw JSONPatchError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.PathElementNotFound)
        }
        guard let operationType = JSONPatchOperation.OperationType(rawValue: operation) else {
            throw JSONPatchError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.InvalidOperation)
        }
        
        // 'from' element mandatory for .move, .copy operations
        var from: JSONPointer?
        if operationType == .move || operationType == .copy {
            guard let fromValue = json[JPSConstants.JsonPatch.Parameter.From].string else {
                throw JSONPatchError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.FromElementNotFound)
            }
            from = try JSONPointer(rawValue: fromValue)
        }
        
        // 'value' element mandatory for .add, .replace operations
        let value = json[JPSConstants.JsonPatch.Parameter.Value]
        // counterintuitive null check: https://github.com/SwiftyJSON/SwiftyJSON/issues/205
        if (operationType == .add || operationType == .replace) && value.null != nil {
            throw JSONPatchError.InvalidPatchFormat(message: JPSConstants.JsonPatch.InitialisationErrorMessages.ValueElementNotFound)
        }
        
        let pointer = try JSONPointer(rawValue: path)
        return JSONPatchOperation(type: operationType, pointer: pointer, value: value, from: from)
    }
    
}
