import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.3
// 4.  Operations
// 4.3. replace
class ReplaceOperationTests: XCTestCase {
    
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
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.5
    func testIfReplaceValueInObjectReturnsExpectedValue() {
        let json = """
        {"baz": "qux", "foo": "bar"}
        """
        let jsonPatch = """
        {"op": "replace", "path": "/baz", "value": "boo"}
        """
        let expectedJSON = """
        {"baz": "boo", "foo": "bar"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfReplaceValueInArrayArrayReturnsExpectedValue() {
        let json = """
        {"foo": [1, 2, 3, 4], "bar": []}
        """
        let jsonPatch = """
        {"op": "replace", "path": "/foo/1", "value": 42}
        """
        let expectedJSON = """
        {"foo": [1, 42, 3, 4], "bar": []}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfMissingValueRaisesError() {
        let jsonPatch = """
        {"op": "replace", "path": "/foo/1"}
        """
        // missing "value"
        XCTAssertThrowsError(try JSONPatch(jsonString: jsonPatch))
    }
}
