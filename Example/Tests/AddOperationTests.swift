import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.1
// 4.  Operations
// 4.1.  add
class AddOperationTests: XCTestCase {
    
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
    
    // reusable method
    private func testPatchFailOperation(json jsonString: String, jsonPatch jsonPatchString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonString: jsonPatchString)
            XCTAssertThrowsError(try JSONPatcher.apply(patch: jsonPatch, to: json))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.1
    func testIfPathToNonExistingMemberCreatesNewMember1() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        {"op": "add", "path": "/baz", "value": "qux"}
        """
        let expectedJSON = """
        {"foo": "bar", "baz": "qux"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.2
    func testIfPathToArrayCreatesNewArrayElement() {
        let json = """
        {"foo": ["bar", "baz"]}
        """
        let jsonPatch = """
        {"op": "add", "path": "/foo/1", "value": "qux"}
        """
        let expectedJSON = """
        {"foo": ["bar", "qux", "baz"]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToArrayInsertsValueAtPositionAndShiftsRemainingMembersRight() {
        let json = """
        ["foo", 42, "bar"]
        """
        let jsonPatch = """
        {"op": "add", "path": "/2", "value": "42"}
        """
        let expectedJSON = """
        ["foo", 42, "42", "bar"]
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToNonExistingMemberCreatesNewMember2() {
        let json = """
        {"foo": {"foo2": "bar"}}
        """
        let jsonPatch = """
        {"op": "add", "path": "/foo/bar", "value": "foo"}
        """
        let expectedJSON = """
        {"foo": {"foo2": "bar", "bar": "foo"}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToNonExistingMemberCreatesNewMember3() {
        let json = """
        {"foo": [{"foo": "bar"}, {"blaa": {"blubb": "bloobb"}}]}
        """
        let jsonPatch = """
        {"op": "add", "path": "/foo/1/blaa/blubby", "value": "foo"}
        """
        let expectedJSON = """
        {"foo": [{"foo": "bar"}, {"blaa": {"blubb": "bloobb", "blubby": "foo"}}]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToExistingMemberReplacesIt1() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        {"op": "add", "path": "/foo", "value": "foobar"}
        """
        let expectedJSON = """
        {"foo": "foobar"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToExistingMemberReplacesIt2() {
        let json = """
        {"foo": [{"foo": "bar"}, {"blaa": {"blubb": "bloobb"}}]}
        """
        let jsonPatch = """
        {"op": "add", "path": "/foo/1/blaa/blubb", "value": "foo"}
        """
        let expectedJSON = """
        {"foo": [{"foo": "bar"}, {"blaa": {"blubb": "foo"}}]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testIfPathToRootReplacesWholeDocument() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        {"op": "add", "path": "", "value": {"bar": "foo"}}
        """
        let expectedJSON = """
        {"bar": "foo"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testAddToArrayWithIndexEqualsCount() {
        let json = """
        {"a": [23, 42]}
        """
        let jsonPatch = """
        {"op": "add", "path": "/a/2", "value": "bar"}
        """
        let expectedJSON = """
        {"a": [23, 42, "bar"]}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
//    func testIfMinusAtEndOfPathAppendsToArray() {
//        let json = """
//        {"foo": ["bar1", "bar2", "bar3"]}
//        """
//        let jsonPatch = """
//        {"op": "add", "path": "/foo/-", "value": "bar4"}
//        """
//        let expectedJSON = """
//        {"foo": ["bar1", "bar2", "bar3", "bar4"]}
//        """
//        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
//    }
    
    func testIfPathElementIsValid() {
        let json = """
        {"a": {"foo": 1}}
        """
        let jsonPatch = """
        {"op": "add", "path": "/a/b", "value": "bar"}
        """
        let expectedJSON = """
        {"a": {"foo": 1, "b": "bar"}}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testAddToArrayWithIndexOutOfBoundsProducesError() {
        let json = """
        {"a": [23, 42]}
        """
        let jsonPatch = """
        {"op": "add", "path": "/a/42", "value": "bar"}
        """
        testPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfInvalidPathElementRaisesError() {
        let json = """
        {"a": {"foo": 1}}
        """
        let jsonPatch = """
        {"op": "add", "path": "/c/b", "value": "bar"}
        """
        testPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
}
