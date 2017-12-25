import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.4
// 4.  Operations
// 4.4.  move
class MoveOperationTests: XCTestCase {
    
    // reusable method
    private func testPatchOperation(json jsonString: String, jsonPatch jsonPatchString: String, expectedJSON expectedJSONString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonString: jsonPatchString)
            let resultingJSON = try JSONPatcher.apply(patch: jsonPatch, to: json)
            let expectedJSON = JSON(parseJSON: expectedJSONString)
            XCTAssertEqual(resultingJSON, expectedJSON)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.6
    func testIfMoveValueInObjectReturnsExpectedValue() {
        let json = """
        {"foo": {"bar": "baz", "waldo": "fred"}, "qux": {"corge": "grault"}}
        """
        let jsonPatch = """
        {"op": "move", "from": "/foo/waldo", "path": "/qux/thud"}
        """
        let expectedJSON = """
        {"foo": {"bar": "baz"}, "qux": {"corge": "grault", "thud": "fred"}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.7
    func testIfMoveIndizesInArrayReturnsExpectedValue() {
        let json = """
        {"foo": ["all", "grass", "cows", "eat"]}
        """
        let jsonPatch = """
        {"op": "move", "from": "/foo/1", "path": "/foo/3"}
        """
        let expectedJSON = """
        {"foo": ["all", "cows", "eat", "grass"]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfObjectKeyMoveOperationReturnsExpectedValue() {
        let json = """
        {"foo": {"1": 2}, "bar": {}}
        """
        let jsonPatch = """
        {"op": "move", "from": "/foo/1", "path": "/bar/1"}
        """
        let expectedJSON = """
        {"foo": {}, "bar": {"1": 2}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfObjectKeyMoveToRootReplacesDocument() {
        let json = """
        {"foo": {"1": 2}, "bar": {}}
        """
        let jsonPatch = """
        {"op": "move", "from": "/foo", "path": ""}
        """
        let expectedJSON = """
        {"1": 2}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfMissingParameterReturnsError() {
        let jsonPatch = """
        {"op": "move", "path": "/bar"}
        """
        // missing "from"
        XCTAssertThrowsError(try JSONPatch(jsonString: jsonPatch))
    }
}
