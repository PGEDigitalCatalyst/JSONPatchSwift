
public enum JSONPatchError: LocalizedError {
    
    case emptyPatchArray
    case invalidRootElement
    case badStringEncoding
    case missingOperationElement
    case missingPathElement
    case missingFromElement
    case missingValueElement
    case invalidOperation
    case testDidFail
    case arrayIndexOutOfBounds
    case invalidJSON
    case pointerValueMissingDelimiter
    case nonEmptyPointerDoesNotStartWithDelimiter
    case pointerContainsEmptyReferenceToken
    
    public var errorDescription: String? {
        switch self {
        case .emptyPatchArray:
            return NSLocalizedString("Patch cannot be an empty array.", comment: "")
        case .invalidRootElement:
            return NSLocalizedString("Patch must be a dictionary or array.", comment: "")
        case .badStringEncoding:
            return NSLocalizedString("Patch string encoding must be UTF-8.", comment: "")
        case .missingOperationElement:
            return NSLocalizedString("Patch must include 'op' element.", comment: "")
        case .missingPathElement:
            return NSLocalizedString("Patch must include 'path' element.", comment: "")
        case .missingFromElement:
            return NSLocalizedString("Patch is missing 'from' element.", comment: "")
        case .missingValueElement:
            return NSLocalizedString("Patch is missing 'value' element.", comment: "")
        case .invalidOperation:
            return NSLocalizedString("Patch 'op' value is invalid.", comment: "")
        case .testDidFail:
            return NSLocalizedString("At least one tested parameter does not match the expected result.", comment: "")
        case .arrayIndexOutOfBounds:
            return NSLocalizedString("Tried to add an element to an array position > array size + 1.", comment: "")
        case .invalidJSON:
            return NSLocalizedString("Invalid JSON provided.", comment: "")
        case .pointerValueMissingDelimiter:
            return NSLocalizedString("JSON pointer values are delimited by a delimiter character", comment: "")
        case .nonEmptyPointerDoesNotStartWithDelimiter:
            return NSLocalizedString("A JSON pointer must start with a delimiter character", comment: "")
        case .pointerContainsEmptyReferenceToken:
            return NSLocalizedString("Every reference token in a JSON pointer must not be empty", comment: "")
        }
    }
}
