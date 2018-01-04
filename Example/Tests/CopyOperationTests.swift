import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.5
// 4.  Operations
// 4.5. copy
class CopyOperationTests: XCTestCase {
    
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
    
    func testIfCopyReplaceValueInObjectReturnsExpectedValue() {
        let json = """
        {"foo": {"1": 2}, "bar": {}}
        """
        let jsonPatch = """
        {"op": "copy", "from": "/foo", "path": "/bar"}
        """
        let expectedJSON = """
        {"foo": {"1": 2}, "bar": {"1": 2}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfCopyArrayReturnsExpectedValue() {
        let json = """
        {"foo": [1, 2, 3, 4], "bar": []}
        """
        let jsonPatch = """
        {"op": "copy", "from": "/foo", "path": "/bar"}
        """
        let expectedJSON = """
        {"foo": [1, 2, 3, 4], "bar": [1, 2, 3, 4]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfCopyArrayOfObjectsReturnsExpectedValue() {
        let json = """
        {"foo": [{"foo": "bar"}], "bar": {}}
        """
        let jsonPatch = """
        {"op": "copy", "from": "/foo/0", "path": "/bar"}
        """
        let expectedJSON = """
        {"foo": [{"foo": "bar"}], "bar": {"foo": "bar"}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfMissingParameterReturnsError() {
        let jsonPatch = """
        {"op": "copy", "path": "/bar"}
        """
        // missing "from"
        XCTAssertThrowsError(try JSONPatch(jsonString: jsonPatch))
    }
}
