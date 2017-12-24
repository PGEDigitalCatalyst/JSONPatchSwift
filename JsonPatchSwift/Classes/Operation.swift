import SwiftyJSON

func == (lhs: JPSOperation, rhs: JPSOperation) -> Bool {
    return lhs.type == rhs.type
}

/// RFC 6902 compliant JavaScript Object Notation (JSON) Patch operation implementation, see https://tools.ietf.org/html/rfc6902#page-4.
public struct JPSOperation {
    
    /// Operation types as stated in https://tools.ietf.org/html/rfc6902#page-4.
    public enum JPSOperationType: String {
        /** Add: The `add` operation. */
        case Add = "add"
        /** Remove: The `remove` operation. */
        case Remove = "remove"
        /** Replace: The `replace` operation. */
        case Replace = "replace"
        /** Move: The `move` operation. */
        case Move = "move"
        /** Copy: The `copy` operation. */
        case Copy = "copy"
        /** Test: The `test` operation. */
        case Test = "test"
    }
    
    let type: JPSOperationType
    let pointer: JPSJsonPointer
    let value: JSON
    let from: JPSJsonPointer?
}
