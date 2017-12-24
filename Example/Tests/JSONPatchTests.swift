import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

class JPSJsonPatchTests: XCTestCase {
    
    // reusable method
    private func testPatchOperation(json jsonString: String, jsonPatch jsonPatchString: String, expectedJSON expectedJSONString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonPatchString)
            let resultingJSON = try JPSJsonPatcher.applyPatch(jsonPatch, toJson: json)
            let expectedJSON = JSON(parseJSON: expectedJSONString)
            XCTAssertEqual(resultingJSON, expectedJSON)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testMultipleOperations1() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        [
            {"op": "remove", "path": "/foo"},
            {"op": "add", "path": "/bar", "value": "foo"}
        ]
        """
        let expectedJSON = """
        {"bar": "foo"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testMultipleOperations2() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        [
            {"op": "add", "path": "/bar", "value": "foo"},
            {"op": "remove", "path": "/foo"}
        ]
        """
        let expectedJSON = """
        {"bar": "foo"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testMultipleOperations3() {
        let json = """
        {"foo": "bar"}
        """
        let jsonPatch = """
        [
            {"op": "remove", "path": "/foo"},
            {"op": "add", "path": "/bar", "value": "foo"},
            {"op": "add", "path": "", "value": {"bla": "blubb"}},
            {"op": "replace", "path": "/bla", "value": "/bla"},
            {"op": "add", "path": "/bla", "value": "blub"},
            {"op": "copy", "from": "/bla", "path": "/blaa"},
            {"op": "move", "from": "/blaa", "path": "/bla"}
        ]
        """
        let expectedJSON = """
        {"bla": "blub"}
        """
        testPatchOperation(json: json, jsonPatch: jsonPatch, expectedJSON: expectedJSON)
    }
    
    func testInitWithSwiftyJSON() {
        let jsonPatchString = """
        {"op": "test", "path": "/a/b/c", "value": "foo"}
        """
        do {
            let jsonPatch0 = try JSONPatch(jsonPatchString)
            let json = JSON(parseJSON: jsonPatchString)
            let jsonPatch1 = try JSONPatch(json)
            XCTAssertEqual(jsonPatch0, jsonPatch1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
