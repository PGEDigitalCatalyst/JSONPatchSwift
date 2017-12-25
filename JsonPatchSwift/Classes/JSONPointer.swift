
import SwiftyJSON

/**
 RFC 6901 compliant JavaScript Object Notation (JSON) Pointer implementation.
 */
public struct JSONPointer {
    
    let rawValue: String
    let pointerValue: [JSONSubscriptType]
}

extension JSONPointer {

    public init(rawValue: String) throws {
        guard (rawValue.isEmpty || rawValue.contains(JPSConstants.JsonPointer.Delimiter)) else { throw JSONPatchError.pointerValueMissingDelimiter }
        guard (rawValue.isEmpty || rawValue.hasPrefix(JPSConstants.JsonPointer.Delimiter)) else { throw JSONPatchError.nonEmptyPointerDoesNotStartWithDelimiter }
        let pointerValueWithoutFirstElement = Array(rawValue.components(separatedBy: JPSConstants.JsonPointer.Delimiter).dropFirst())
        guard rawValue.isEmpty || !pointerValueWithoutFirstElement.contains(JPSConstants.JsonPointer.EmptyString) else { throw JSONPatchError.pointerContainsEmptyReferenceToken }
        let pointerValueAfterDecodingDelimiter = pointerValueWithoutFirstElement.map({ $0.replacingOccurrences(of: JPSConstants.JsonPointer.EscapedDelimiter, with: JPSConstants.JsonPointer.Delimiter) })
        let pointerValue: [JSONSubscriptType] = pointerValueAfterDecodingDelimiter.map({ $0.replacingOccurrences(of: JPSConstants.JsonPointer.EscapedEscapeCharacter, with: JPSConstants.JsonPointer.EscapeCharater)})
        self.init(rawValue: rawValue, pointerValue: pointerValue)
    }
}

extension JSONPointer {
    static func traverse(_ pointer: JSONPointer) -> JSONPointer {
        let pointerValueWithoutFirstElement = Array(pointer.rawValue.components(separatedBy: JPSConstants.JsonPointer.Delimiter).dropFirst().dropFirst()).joined(separator: JPSConstants.JsonPointer.Delimiter)
        return try! JSONPointer(rawValue: JPSConstants.JsonPointer.Delimiter + pointerValueWithoutFirstElement)
    }
}

extension JSONPointer: Equatable {
    public static func ==(lhs: JSONPointer, rhs: JSONPointer) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
