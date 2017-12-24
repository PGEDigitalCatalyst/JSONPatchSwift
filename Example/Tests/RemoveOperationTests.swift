import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.2
// 4.  Operations
// 4.2.  remove
class JPSRemoveOperationTests: XCTestCase {
    
    // reusable method
    private func testPatchOperation(json jsonString: String, jsonPatch jsonPatchString: String, expectedJSON expectedJSONString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonPatchString)
            let resultingJSON = try JSONPatcher.apply(patch: jsonPatch, to: json)
            let expectedJSON = JSON(parseJSON: expectedJSONString)
            XCTAssertEqual(resultingJSON, expectedJSON)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.3
    func testIfDeleteObjectMemberReturnsExpectedValue() {
        let json = """
        {"baz": "qux", "foo": "bar"}
        """
        let jsonPatch = """
        {"op": "remove", "path": "/baz"}
        """
        let expectedJSON = """
        {"foo": "bar"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.4
    func testIfDeleteArrayElementReturnsExpectedValue() {
        let json = """
        {"foo": ["bar", "qux", "baz"]}
        """
        let jsonPatch = """
        {"op": "remove", "path": "/foo/1"}
        """
        let expectedJSON = """
        {"foo": ["bar", "baz"]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }

    func testIfDeleteLastElementReturnsEmptyJson() {
        let json = """
        {"foo": "1"}
        """
        let jsonPatch = """
        {"op": "remove", "path": "/foo"}
        """
        let expectedJSON = """
        {}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }

    func testIfDeleteSubElementReturnsEmptyTopElement() {
        let json = """
        {"foo": {"bar": "1"}}
        """
        let jsonPatch = """
        {"op": "remove", "path": "/foo/bar"}
        """
        let expectedJSON = """
        {"foo": {}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }

    // FIXME: This isn't even the right test
//    func testIfDeleteLastArrayElementReturnsEmptyArray() {
//        let json = """
//        {"foo": {"bar": "1"}}
//        """
//        let jsonPatch = """
//        {"op": "remove", "path": "/foo/bar"}
//        """
//        let expectedJSON = """
//        {"foo": {}}
//        """
//        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
//    }

    func testIfDeleteFromArrayDeletesTheExpectedKey() {
        let json = """
        ["foo", 42, "bar"]
        """
        let jsonPatch = """
        {"op": "remove", "path": "/2"}
        """
        let expectedJSON = """
        ["foo", 42]
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }

    func testIfDeleteFromMultiDimensionalArrayDeletesTheExpectedKey() {
        let json = """
        ["foo", ["foo", 3, "42"], "bar"]
        """
        let jsonPatch = """
        {"op": "remove", "path": "/1/2"}
        """
        let expectedJSON = """
        ["foo", ["foo", 3], "bar"]
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
}
