
import SwiftyJSON

/// RFC 6902 compliant JavaScript Object Notation (JSON) Patch operation implementation, see https://tools.ietf.org/html/rfc6902#page-4.
public struct JSONPatchOperation {
    
    /// Operation types as stated in https://tools.ietf.org/html/rfc6902#page-4.
    public enum OperationType: String {
        /** add: The `add` operation. */
        case add = "add"
        /** remove: The `remove` operation. */
        case remove = "remove"
        /** replace: The `replace` operation. */
        case replace = "replace"
        /** move: The `move` operation. */
        case move = "move"
        /** copy: The `copy` operation. */
        case copy = "copy"
        /** test: The `test` operation. */
        case test = "test"
    }
    
    let type: OperationType
    let pointer: JSONPointer
    let value: JSON
    let from: JSONPointer?
}

extension JSONPatchOperation: Equatable {
    
    public static func ==(lhs: JSONPatchOperation, rhs: JSONPatchOperation) -> Bool {
        return lhs.type == rhs.type
            && lhs.pointer == rhs.pointer
            && lhs.value == rhs.value
            && lhs.from == rhs.from
    }
}
