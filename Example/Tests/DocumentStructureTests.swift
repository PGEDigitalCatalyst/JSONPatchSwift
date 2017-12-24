import XCTest
@testable import JsonPatchSwift

// http://tools.ietf.org/html/rfc6902#section-3
// 3. Document Structure (and the general Part of Chapter 4)

class JPSDocumentStructureTests: XCTestCase {
    
    func testJsonPatchContainsArrayOfOperations() {
        let jsonPatchString = """
        [
            {"op": "test", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJsonPatchReadsAllOperations() {
        let jsonPatchString = """
        [
            {"op": "test", "path": "/a/b/c", "value": "foo"},
            {"op": "test", "path": "/a/b/c", "value": "foo"},
            {"op": "test", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJsonPatchOperationsHaveSameOrderAsInJsonRepresentation() {
        let jsonPatchString = """
        [
            {"op": "add", "path": "/a/b/c", "value": "foo"},
            {"op": "remove", "path": "/a/b/c"},
            {"op": "replace", "path": "/a/b/c", "value": "foo"},
            {"op": "move", "from": "/a/b/c", "path": "/d/e/f"},
            {"op": "copy", "from": "/a/b/c", "path": "/d/e/f"},
            {"op": "test", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 6)
            XCTAssertEqual(jsonPatch.operations[0].type, JPSOperation.JPSOperationType.Add)
            XCTAssertEqual(jsonPatch.operations[1].type, JPSOperation.JPSOperationType.Remove)
            XCTAssertEqual(jsonPatch.operations[2].type, JPSOperation.JPSOperationType.Replace)
            XCTAssertEqual(jsonPatch.operations[3].type, JPSOperation.JPSOperationType.Move)
            XCTAssertEqual(jsonPatch.operations[4].type, JPSOperation.JPSOperationType.Copy)
            XCTAssertEqual(jsonPatch.operations[5].type, JPSOperation.JPSOperationType.Test)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // This is about the JSON format in general.
    func testJsonPatchRejectsInvalidJsonFormat() {
        let jsonPatchString = "!#€%&/()*^*_:;;:;_poawolwasnndaw"
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }

    func testJsonPatchRejectsMissingOperation() {
        let jsonPatchString = """
        {"path": "/a/b/c", "value": "foo"}
        """
        // missing "operation"
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }
    
    func testJsonPatchRejectsMissingPath() {
        let jsonPatchString = """
        {"op": "add", "value": "foo"}
        """
        // missing "path"
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }
    
    func testJsonPatchRejectsMissingValue() {
        let jsonPatchString = """
        {"op": "add", "path": "/foo"}
        """
        // missing "value"
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }
    
    func testJsonPatchSavesValue() {
        let jsonPatchString = """
        [
            {"op": "test", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].value.string, "foo")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJsonPatchRejectsEmptyArray() {
        XCTAssertThrowsError(try JPSJsonPatch("[]"))
    }
    
    func testInvalidJsonGetsRejected() {
        XCTAssertThrowsError(try JPSJsonPatch("{op:foo}"))
    }
    
    func testInvalidOperationsAreRejected() {
        let jsonPatchString = """
        {"op": "foo", "path": "/a/b"}
        """
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }
    
    // JSON Pointer: RFC6901
    // Multiple tests necessary here
    func testIfPathContainsValidJsonPointer() {
        let jsonPatchString = """
        {"op": "add", "path": "foo", "value": "foo"}
        """
        // invalid path
        XCTAssertThrowsError(try JPSJsonPatch(jsonPatchString))
    }
    
    func testIfAdditionalElementsAreIgnored() {
        let jsonPatchString = """
        {"op": "test", "path": "/a/b/c", "value": "foo", "additionalParameter": "foo"}
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].type, JPSOperation.JPSOperationType.Test)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfElementsNotNecessaryForOperationAreIgnored() {
        let jsonPatchString = """
        {"op": "remove", "path": "/a/b/c", "value": "foo", "additionalParameter": "foo"}
        """
        do {
            let jsonPatch = try JPSJsonPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].type, JPSOperation.JPSOperationType.Remove)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
   
    func testEqualityOperatorWithDifferentAmountsOfOperations() {
        let jsonPatchString0 = """
        [
            {"op": "add", "path": "/a/b/c", "value": "foo"}
        ]
        """
        let jsonPatchString1 = """
        [
            {"op": "test", "path": "/a/b/c", "value": "foo"},
            {"op": "add", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch0 = try JPSJsonPatch(jsonPatchString0)
            let jsonPatch1 = try JPSJsonPatch(jsonPatchString1)
            XCTAssertNotEqual(jsonPatch0, jsonPatch1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEqualityOperatorWithDifferentOperations() {
        let jsonPatchString0 = """
        {"op": "add", "path": "/a/b/c", "value": "foo"}
        """
        let jsonPatchString1 = """
        {"op": "remove", "path": "/a/b/c"}
        """
        do {
            let jsonPatch0 = try JPSJsonPatch(jsonPatchString0)
            let jsonPatch1 = try JPSJsonPatch(jsonPatchString1)
            XCTAssertNotEqual(jsonPatch0, jsonPatch1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
