
import SwiftyJSON

/**
 RFC 6902 compliant JSONPatch implementation.
 */
public struct JSONPatcher {
    
    /**
     Applies a given `JSONPatch` to a `JSON`.
     - Parameter jsonPatch: the jsonPatch to apply
     - Parameter json: the json to apply the patch to
     - Throws: can throw any error from `JSONPatcher.JPSJsonPatcherApplyError` to
     notify about failed operations.
     - Returns: A new `JSON` containing the given `JSON` with the patch applied.
     */
    public static func apply(patch: JSONPatch, to json: JSON) throws -> JSON {
        var tempJson = json
        for operation in patch.operations {
            switch operation.type {
            case .add: tempJson = try JSONPatcher.add(operation, toJson: tempJson)
            case .remove: tempJson = try JSONPatcher.remove(operation, toJson: tempJson)
            case .replace: tempJson = try JSONPatcher.replace(operation, toJson: tempJson)
            case .move: tempJson = try JSONPatcher.move(operation, toJson: tempJson)
            case .copy: tempJson = try JSONPatcher.copy(operation, toJson: tempJson)
            case .test: tempJson = try JSONPatcher.test(operation, toJson: tempJson)
            }
        }
        return tempJson
    }
    
    /// Possible errors thrown by the applyPatch function.
    public enum JPSJsonPatcherApplyError: Error {
        /** ValidationError: `test` operation did not succeed. At least one tested parameter does not match the expected result. */
        case ValidationError(message: String?)
        /** ArrayIndexOutOfBounds: tried to add an element to an array position > array size + 1. See: http://tools.ietf.org/html/rfc6902#section-4.1 */
        case ArrayIndexOutOfBounds
        /** InvalidJson: invalid `JSON` provided. */
        case InvalidJson
    }
}


// MARK: - Private functions
extension JSONPatcher {
    private static func add(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        
        guard 0 < operation.pointer.pointerValue.count else {
            return operation.value
        }
        
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson, pointer) -> JSON in
            var newJson = traversedJson
            if var jsonAsDictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                jsonAsDictionary[key] = operation.value.object
                newJson.object = jsonAsDictionary
            } else if var jsonAsArray = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard index <= jsonAsArray.count else {
                    throw JPSJsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                jsonAsArray.insert(operation.value.object, at: index)
                newJson.object = jsonAsArray
            }
            return newJson
        }
    }
    
    private static func remove(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JSONPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                dictionary.removeValue(forKey: key)
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr.remove(at: index)
                newJson.object = arr
            }
            return newJson
        }
    }
    
    private static func replace(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JSONPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                dictionary[key] = operation.value.object
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr[index] = operation.value.object
                newJson.object = arr
            }
            return newJson
        }
    }
    
    private static func move(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JSONPatcher.applyOperation(json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JSONPointer) in
            
            // From: http://tools.ietf.org/html/rfc6902#section-4.3
            //    This operation is functionally identical to a "remove" operation for
            //    a value, followed immediately by an "add" operation at the same
            //    location with the replacement value.
            
            // remove
            let removeOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.remove, pointer: operation.from!, value: resultJson, from: operation.from)
            resultJson = try JSONPatcher.remove(removeOperation, toJson: resultJson)
            
            // add
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JSONPatcher.add(addOperation, toJson: resultJson)
            
            return traversedJson
        }
        
        return resultJson
    }
    
    private static func copy(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JSONPatcher.applyOperation(json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JSONPointer) in
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JSONPatcher.add(addOperation, toJson: resultJson)
            return traversedJson
        }
        
        return resultJson
        
    }
    
    private static func test(_ operation: JSONPatchOperation, toJson json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JSONPointer) in
            let jsonToValidate = traversedJson[pointer.pointerValue]
            guard jsonToValidate == operation.value else {
                throw JPSJsonPatcherApplyError.ValidationError(message: JPSConstants.JsonPatch.ErrorMessages.ValidationError)
            }
            return traversedJson
        }
    }
    
    private static func applyOperation(_ json: JSON?, pointer: JSONPointer, operation: ((JSON, JSONPointer) throws -> JSON)) throws -> JSON {
        guard let newJson = json else {
            throw JPSJsonPatcherApplyError.InvalidJson
        }
        if pointer.pointerValue.count == 1 {
            return try operation(newJson, pointer)
        } else {
            if var arr = newJson.array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr[index] = try applyOperation(arr[index], pointer: JSONPointer.traverse(pointer), operation: operation)
                return JSON(arr)
            }
            if var dictionary = newJson.dictionary, let key = pointer.pointerValue.first as? String {
                dictionary[key] = try applyOperation(dictionary[key], pointer: JSONPointer.traverse(pointer), operation: operation)
                return JSON(dictionary)
            }
        }
        return newJson
    }
    
}
