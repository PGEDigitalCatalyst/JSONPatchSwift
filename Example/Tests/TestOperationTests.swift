import XCTest
@testable import JsonPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.6
// 4.  Operations
// 4.6. test
class JPSTestOperationTests: XCTestCase {
    
    private func testTestPatchOperation(json jsonString: String, jsonPatch jsonPatchString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonPatchString)
            let resultingJSON = try JSONPatcher.applyPatch(jsonPatch, toJson: json)
            XCTAssertEqual(json, resultingJSON)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    private func testTestPatchFailOperation(json jsonString: String, jsonPatch jsonPatchString: String) {
        do {
            let json = JSON(parseJSON: jsonString)
            let jsonPatch = try JSONPatch(jsonPatchString)
            XCTAssertThrowsError(try JSONPatcher.applyPatch(jsonPatch, toJson: json))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfBasicStringCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": "2"}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo/1", "value": "2"}
        """
        testTestPatchOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfInvalidBasicStringCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": "2"}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo/1", "value": "3"}
        """
        testTestPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfBasicIntCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": 2}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo/1", "value": 2}
        """
        testTestPatchOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfInvalidBasicIntCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": 2}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo/1", "value": 3}
        """
        testTestPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfBasicObjectCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": 2}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo", "value": {"1": 2}}
        """
        testTestPatchOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfInvalidBasicObjectCheckReturnsExpectedResult() {
        let json = """
        {"foo": {"1": "2"}}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo", "value": {"1": 3}}
        """
        testTestPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfBasicArrayCheckReturnsExpectedResult() {
        let json = """
        {"foo": [1, 2, 3, 4, 5]}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo", "value": [1, 2, 3, 4, 5]}
        """
        testTestPatchOperation(json: json, jsonPatch: jsonPatch)
    }
    
    func testIfInvalidBasicArrayCheckReturnsExpectedResult() {
        let json = """
        {"foo": [1, 2, 3, 4, 5]}
        """
        let jsonPatch = """
        {"op": "test", "path": "/foo", "value": [1, 2, 3, 4, 5, 6, 7, 42]}
        """
        testTestPatchFailOperation(json: json, jsonPatch: jsonPatch)
    }
}
