
import SwiftyJSON

/**
 RFC 6902 compliant JSONPatch implementation.
 */
public struct JSONPatcher {
    
    public static func apply(patch: JSONPatch, to json: JSON) throws -> JSON {
        var tempJson = json
        for operation in patch.operations {
            switch operation.type {
            case .add: tempJson = try JSONPatcher.add(operation, to: tempJson)
            case .remove: tempJson = try JSONPatcher.remove(operation, to: tempJson)
            case .replace: tempJson = try JSONPatcher.replace(operation, to: tempJson)
            case .move: tempJson = try JSONPatcher.move(operation, to: tempJson)
            case .copy: tempJson = try JSONPatcher.copy(operation, to: tempJson)
            case .test: tempJson = try JSONPatcher.test(operation, to: tempJson)
            }
        }
        return tempJson
    }
    
    /// Possible errors thrown by the applyPatch function.
    public enum JSONPatcherError: Error {
        /** validationError: `test` operation did not succeed. At least one tested parameter does not match the expected result. */
        case validationError
        /** arrayIndexOutOfBounds: tried to add an element to an array position > array size + 1. See: http://tools.ietf.org/html/rfc6902#section-4.1 */
        case arrayIndexOutOfBounds
        /** invalidJSON: invalid `JSON` provided. */
        case invalidJSON
    }
}

// MARK: - Private functions

extension JSONPatcher {
    
    private static func add(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        guard !operation.pointer.pointerValue.isEmpty else { return operation.value }
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) { (traversedJson, pointer) -> JSON in
            var newJson = traversedJson
            if var jsonAsDictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                jsonAsDictionary[key] = operation.value.object
                newJson.object = jsonAsDictionary
            } else if var jsonAsArray = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard index <= jsonAsArray.count else { throw JSONPatcherError.arrayIndexOutOfBounds }
                jsonAsArray.insert(operation.value.object, at: index)
                newJson.object = jsonAsArray
            }
            return newJson
        }
    }
    
    private static func remove(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) { (traversedJson: JSON, pointer: JSONPointer) in
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
    
    private static func replace(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) { (traversedJson: JSON, pointer: JSONPointer) in
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
    
    private static func move(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        var resultJson = json
        _ = try JSONPatcher.applyOperation(json, pointer: operation.from!) { (traversedJson: JSON, pointer: JSONPointer) in
            
            // From: http://tools.ietf.org/html/rfc6902#section-4.3
            //    This operation is functionally identical to a "remove" operation for
            //    a value, followed immediately by an "add" operation at the same
            //    location with the replacement value.
            
            // remove
            let removeOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.remove, pointer: operation.from!, value: resultJson, from: operation.from)
            resultJson = try JSONPatcher.remove(removeOperation, to: resultJson)
            
            // add
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JSONPatcher.add(addOperation, to: resultJson)
            
            return traversedJson
        }
        
        return resultJson
    }
    
    private static func copy(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        var resultJson = json
        _ = try JSONPatcher.applyOperation(json, pointer: operation.from!) { (traversedJson: JSON, pointer: JSONPointer) in
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JSONPatchOperation(type: JSONPatchOperation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JSONPatcher.add(addOperation, to: resultJson)
            return traversedJson
        }
        
        return resultJson
        
    }
    
    private static func test(_ operation: JSONPatchOperation, to json: JSON) throws -> JSON {
        return try JSONPatcher.applyOperation(json, pointer: operation.pointer) { (traversedJson: JSON, pointer: JSONPointer) in
            let jsonToValidate = traversedJson[pointer.pointerValue]
            guard jsonToValidate == operation.value else { throw JSONPatcherError.validationError }
            return traversedJson
        }
    }
    
    private static func applyOperation(_ json: JSON?, pointer: JSONPointer, operation: ((JSON, JSONPointer) throws -> JSON)) throws -> JSON {
        guard let newJson = json else { throw JSONPatcherError.invalidJSON }
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
