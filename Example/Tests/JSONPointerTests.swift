import SwiftyJSON
import XCTest
@testable import JsonPatchSwift

// JavaScript Object Notation (JSON) Pointer
// https://tools.ietf.org/html/rfc6901
class JPSJsonPointerTests: XCTestCase {

    // MARK: - chapter 3 tests
    
    func testIfEmptyPointerIsValid() {
        do {
            let jsonPointer = try JPSJsonPointer(rawValue: "")
            XCTAssertEqual(jsonPointer.rawValue, "")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfJsonPointerIsAString() {
        do {
            let jsonPointer = try JPSJsonPointer(rawValue: "/a/b")
            XCTAssertEqual(jsonPointer.rawValue, "/a/b")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfJsoinPointerRejectsInputWithoutSlashDelimiter() {
        XCTAssertThrowsError(try JPSJsonPointer(rawValue: "ab"))
    }
    
    func testIfNonEmptyJsonPointerStartsWithDelimiter() {
        XCTAssertThrowsError(try JPSJsonPointer(rawValue: "a/b/c"))
    }
    
    func testIfEmptyReferenceTokenIsInvalid() {
        XCTAssertThrowsError(try JPSJsonPointer(rawValue: "/a//c"))
    }
    
    func testIfPointerOnlyContainingDelimiterIsInvalid() {
        XCTAssertThrowsError(try JPSJsonPointer(rawValue: JPSConstants.JsonPointer.Delimiter))
    }
    
    func testForSeveralUnicodeCharacters() {
        let rawValue = "/1234567890-=!@£$%^&*()_+¡€#¢∞§¶•ªº–≠⁄™‹›ﬁﬂ‡°·‚—±qwertyuiop[]QWERTYUIOP{}œ∑´®†¥¨^øπ“‘Œ„‰ÂÊÁËÈØ∏’asdfghjkl;'ASDFGHJKL:|åß∂ƒ©˙∆˚¬…æ«ÅÍÎÏÌÓÔÒÚÆ»`zxcvbnm,./~ZXCVBNM<>?`Ω≈ç√∫~µ≤≥÷ŸÛÙÇ◊ıˆ˜¯˘¿"
        do {
            let jsonPointer = try JPSJsonPointer(rawValue: rawValue)
            XCTAssertEqual(jsonPointer.rawValue, rawValue)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    //    The ABNF syntax of a JSON Pointer is:
    //
    //    json-pointer    = *( JPSConstants.JsonPointer.Delimiter reference-token )
    //    reference-token = *( unescaped / escaped )
    //    unescaped       = %x00-2E / %x30-7D / %x7F-10FFFF
    //    ; %x2F ('/') and %x7E ('~') are excluded from 'unescaped'
    //    escaped         = JPSConstants.JsonPointer.EscapeCharater ( "0" / "1" )
    //    ; representing '~' and '/', respectively
    //
    //    It is an error condition if a JSON Pointer value does not conform to
    //    this syntax (see Section 7).
    //
    //    Note that JSON Pointers are specified in characters, not as bytes.
    
    
}


// MARK: - chapter 4 tests
extension JPSJsonPointerTests {
    
    // TODO: Validate these tests are meaningful
    func testIfTildeEscapedCharactersAreDecoded() {
        do {
            let jsonPointer1 = try JPSJsonPointer(rawValue: "/~1")
            XCTAssertEqual(jsonPointer1.pointerValue.count, 1)
            XCTAssertEqual(jsonPointer1.pointerValue.first as? String, JPSConstants.JsonPointer.Delimiter)
            let jsonPointer2 = try JPSJsonPointer(rawValue: "/~0")
            XCTAssertEqual(jsonPointer2.pointerValue.count, 1)
            XCTAssertEqual(jsonPointer2.pointerValue.first as? String, JPSConstants.JsonPointer.EscapeCharater)
            let jsonPointer3 = try JPSJsonPointer(rawValue: "/~01")
            XCTAssertEqual(jsonPointer3.pointerValue.count, 1)
            XCTAssertEqual(jsonPointer3.pointerValue.first as? String, JPSConstants.JsonPointer.EscapedDelimiter)
            let jsonPointer4 = try JPSJsonPointer(rawValue: "/~10")
            XCTAssertEqual(jsonPointer4.pointerValue.count, 1)
            XCTAssertEqual(jsonPointer4.pointerValue.first as? String, "/0")
            let jsonPointer5 = try JPSJsonPointer(rawValue: "/~1~0")
            XCTAssertEqual(jsonPointer5.pointerValue.count, 1)
            XCTAssertEqual(jsonPointer5.pointerValue.first as? String, "/~")
            let jsonPointer6 = try JPSJsonPointer(rawValue: "/~1/~0")
            XCTAssertEqual(jsonPointer6.pointerValue.count, 2)
            XCTAssertEqual(jsonPointer6.pointerValue.first as? String, JPSConstants.JsonPointer.Delimiter)
            XCTAssertEqual(jsonPointer6.pointerValue[1] as? String, JPSConstants.JsonPointer.EscapeCharater)
            let jsonPointer7 = try JPSJsonPointer(rawValue: "/~0/~1")
            XCTAssertEqual(jsonPointer7.pointerValue.count, 2)
            XCTAssertEqual(jsonPointer7.pointerValue.first as? String, JPSConstants.JsonPointer.EscapeCharater)
            XCTAssertEqual(jsonPointer7.pointerValue[1] as? String, JPSConstants.JsonPointer.Delimiter)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    //
    //    Implementations will evaluate each reference token against the
    //    document's contents and will raise an error condition if it fails to
    //    resolve a concrete value for any of the JSON pointer's reference
    //    tokens.  For example, if an array is referenced with a non-numeric
    //    token, an error condition will be raised.  See Section 7 for details.
    //
    //    Note that the use of the "-" character to index an array will always
    //    result in such an error condition because by definition it refers to
    //    a nonexistent array element.  Thus, applications of JSON Pointer need
    //    to specify how that character is to be handled, if it is to be
    //    useful.
    //
    //    Any error condition for which a specific action is not defined by the
    //    JSON Pointer application results in termination of evaluation.
    
    
}


// MARK: - chapter 6 tests
extension JPSJsonPointerTests {
    
    
    //
    //    6.  URI Fragment Identifier Representation
    //
    //    A JSON Pointer can be represented in a URI fragment identifier by
    //    encoding it into octets using UTF-8 [RFC3629], while percent-encoding
    //    those characters not allowed by the fragment rule in [RFC3986].
    //
    //    Note that a given media type needs to specify JSON Pointer as its
    //    fragment identifier syntax explicitly (usually, in its registration
    //    [RFC6838]).  That is, just because a document is JSON does not imply
    //    that JSON Pointer can be used as its fragment identifier syntax.  In
    //    particular, the fragment identifier syntax for application/json is
    //    not JSON Pointer.
    //
    //    Given the same example document as above, the following URI fragment
    //    identifiers evaluate to the accompanying values:
    //
    //    #            // the whole document
    //    #/foo        ["bar", "baz"]
    //    #/foo/0      "bar"
    //    #/           0
    //    #/a~1b       1
    //    #/c%25d      2
    //    #/e%5Ef      3
    //    #/g%7Ch      4
    //    #/i%5Cj      5
    //    #/k%22l      6
    //    #/%20        7
    //    #/m~0n       8
    
    
    
}


// MARK: - chapter 7 tests
extension JPSJsonPointerTests {
    
    
    //
    //    7.  Error Handling
    //
    //    In the event of an error condition, evaluation of the JSON Pointer
    //    fails to complete.
    //
    //    Error conditions include, but are not limited to:
    //
    //    o  Invalid pointer syntax
    //
    //    o  A pointer that references a nonexistent value
    //
    //    This specification does not define how errors are handled.  An
    //    application of JSON Pointer SHOULD specify the impact and handling of
    //    each type of error.
    //
    //    For example, some applications might stop pointer processing upon an
    //    error, while others may attempt to recover from missing values by
    //    inserting default ones.
    
    
    
}


// MARK: - chapter 8 tests
extension JPSJsonPointerTests {
    
    
    //
    //    8.  Security Considerations
    //
    //    A given JSON Pointer is not guaranteed to reference an actual JSON
    //    value.  Therefore, applications using JSON Pointer should anticipate
    //    this situation by defining how a pointer that does not resolve ought
    //    to be handled.
    //
    //    Note that JSON pointers can contain the NUL (Unicode U+0000)
    //    character.  Care is needed not to misinterpret this character in
    //    programming languages that use NUL to mark the end of a string.
    //
    //
    
}

// MARK: - misc tests
extension JPSJsonPointerTests {
    
    func testIfTraverseReturnsNextPointer() {
        do {
            let pointer = try JPSJsonPointer(rawValue: "/a/b")
            let newPointer = JPSJsonPointer.traverse(pointer)
            XCTAssertEqual(newPointer.rawValue, "/b")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfDeepTraverseReturnsNextPointer() {
        do {
            let pointer = try JPSJsonPointer(rawValue: "/abc/b/hallo/welt")
            let newPointer = JPSJsonPointer.traverse(pointer)
            XCTAssertEqual(newPointer.rawValue, "/b/hallo/welt")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
