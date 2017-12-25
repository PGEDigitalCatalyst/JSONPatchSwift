
import SwiftyJSON

/**
 RFC 6901 compliant JavaScript Object Notation (JSON) Pointer implementation.
 */
public struct JSONPointer {
    
    public let rawValue: String
    public let pointerValue: [JSONSubscriptType]

    public init(rawValue: String) throws {
        guard (rawValue.isEmpty || rawValue.contains(JSONPointer.delimiter)) else { throw JSONPatchError.pointerValueMissingDelimiter }
        guard (rawValue.isEmpty || rawValue.hasPrefix(JSONPointer.delimiter)) else { throw JSONPatchError.nonEmptyPointerDoesNotStartWithDelimiter }
        let pointerValueWithoutFirstElement = Array(rawValue.components(separatedBy: JSONPointer.delimiter).dropFirst())
        guard rawValue.isEmpty || !pointerValueWithoutFirstElement.contains(JSONPointer.emptyString) else { throw JSONPatchError.pointerContainsEmptyReferenceToken }
        let pointerValueAfterDecodingDelimiter = pointerValueWithoutFirstElement.map({ $0.replacingOccurrences(of: JSONPointer.escapedDelimiter, with: JSONPointer.delimiter) })
        let pointerValue: [JSONSubscriptType] = pointerValueAfterDecodingDelimiter.map({ $0.replacingOccurrences(of: JSONPointer.escapedEscapeCharacter, with: JSONPointer.escapeCharacter)})
        self.init(rawValue: rawValue, pointerValue: pointerValue)
    }
    
    public init(rawValue: String, pointerValue: [JSONSubscriptType]) {
        self.rawValue = rawValue
        self.pointerValue = pointerValue
    }
}

extension JSONPointer {
    static let delimiter = "/"
    static let endOfArrayMarker = "-"
    static let emptyString = ""
    static let escapeCharacter = "~"
    static let escapedDelimiter = "~1"
    static let escapedEscapeCharacter = "~0"
    
    static func traverse(_ pointer: JSONPointer) -> JSONPointer {
        let pointerValueWithoutFirstElement = Array(pointer.rawValue.components(separatedBy: delimiter).dropFirst().dropFirst()).joined(separator: delimiter)
        return try! JSONPointer(rawValue: delimiter + pointerValueWithoutFirstElement)
    }
}

extension JSONPointer: Equatable {
    public static func ==(lhs: JSONPointer, rhs: JSONPointer) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
