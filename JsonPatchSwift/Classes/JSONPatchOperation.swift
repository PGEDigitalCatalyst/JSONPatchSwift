
import SwiftyJSON

/**
 RFC 6902 compliant JavaScript Object Notation (JSON) Patch operation implementation.
 see https://tools.ietf.org/html/rfc6902#page-4.
 */
public struct JSONPatchOperation {
    
    public let type: OperationType
    public let pointer: JSONPointer
    public let value: JSON
    public let from: JSONPointer?
    
    /**
     Operation types as stated in https://tools.ietf.org/html/rfc6902#page-4.
     */
    public enum OperationType: String {
        case add
        case remove
        case replace
        case move
        case copy
        case test
    }
}

extension JSONPatchOperation: Equatable {
    
    public static func ==(lhs: JSONPatchOperation, rhs: JSONPatchOperation) -> Bool {
        return lhs.type == rhs.type
            && lhs.pointer == rhs.pointer
            && lhs.value == rhs.value
            && lhs.from == rhs.from
    }
}
