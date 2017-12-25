
import SwiftyJSON

public struct JSONPatch {
    
    public let operations: [JSONPatchOperation]
    
    public init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else { throw JSONPatchError.badStringEncoding }
        let json = try JSON(data: data, options: .allowFragments)
        try self.init(json: json)
    }
    
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


extension JSONPatch {
    
    private enum Parameter: String {
        case op
        case path
        case value
        case from
    }
    
    private static func extractOperation(from json: JSON) throws -> JSONPatchOperation {
        guard let operation = json[Parameter.op.rawValue].string else { throw JSONPatchError.missingOperationElement }
        guard let path = json[Parameter.path.rawValue].string else { throw JSONPatchError.missingPathElement }
        guard let operationType = JSONPatchOperation.OperationType(rawValue: operation) else { throw JSONPatchError.invalidOperation }
        
        var from: JSONPointer?
        if (operationType == .move || operationType == .copy) {
            // 'from' element mandatory for .move, .copy operations
            guard let fromValue = json[Parameter.from.rawValue].string else { throw JSONPatchError.missingFromElement }
            from = try JSONPointer(rawValue: fromValue)
        }
        
        let value = json[Parameter.value.rawValue]
        // 'value' element mandatory for .add, .replace operations
        // counterintuitive null check: https://github.com/SwiftyJSON/SwiftyJSON/issues/205
        if (operationType == .add || operationType == .replace) && (value.null != nil) { throw JSONPatchError.missingValueElement }
        
        let pointer = try JSONPointer(rawValue: path)
        return JSONPatchOperation(type: operationType, pointer: pointer, value: value, from: from)
    }
}
