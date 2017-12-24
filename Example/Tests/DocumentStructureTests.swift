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
            let jsonPatch = try JSONPatch(jsonPatchString)
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
            let jsonPatch = try JSONPatch(jsonPatchString)
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
            let jsonPatch = try JSONPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 6)
            XCTAssertEqual(jsonPatch.operations[0].type, JSONPatchOperation.OperationType.add)
            XCTAssertEqual(jsonPatch.operations[1].type, JSONPatchOperation.OperationType.remove)
            XCTAssertEqual(jsonPatch.operations[2].type, JSONPatchOperation.OperationType.replace)
            XCTAssertEqual(jsonPatch.operations[3].type, JSONPatchOperation.OperationType.move)
            XCTAssertEqual(jsonPatch.operations[4].type, JSONPatchOperation.OperationType.copy)
            XCTAssertEqual(jsonPatch.operations[5].type, JSONPatchOperation.OperationType.test)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // This is about the JSON format in general.
    func testJsonPatchRejectsInvalidJsonFormat() {
        let jsonPatchString = "!#€%&/()*^*_:;;:;_poawolwasnndaw"
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }

    func testJsonPatchRejectsMissingOperation() {
        let jsonPatchString = """
        {"path": "/a/b/c", "value": "foo"}
        """
        // missing "operation"
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }
    
    func testJsonPatchRejectsMissingPath() {
        let jsonPatchString = """
        {"op": "add", "value": "foo"}
        """
        // missing "path"
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }
    
    func testJsonPatchRejectsMissingValue() {
        let jsonPatchString = """
        {"op": "add", "path": "/foo"}
        """
        // missing "value"
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }
    
    func testJsonPatchSavesValue() {
        let jsonPatchString = """
        [
            {"op": "test", "path": "/a/b/c", "value": "foo"}
        ]
        """
        do {
            let jsonPatch = try JSONPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].value.string, "foo")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJsonPatchRejectsEmptyArray() {
        XCTAssertThrowsError(try JSONPatch("[]"))
    }
    
    func testInvalidJsonGetsRejected() {
        XCTAssertThrowsError(try JSONPatch("{op:foo}"))
    }
    
    func testInvalidOperationsAreRejected() {
        let jsonPatchString = """
        {"op": "foo", "path": "/a/b"}
        """
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }
    
    // JSON Pointer: RFC6901
    // Multiple tests necessary here
    func testIfPathContainsValidJsonPointer() {
        let jsonPatchString = """
        {"op": "add", "path": "foo", "value": "foo"}
        """
        // invalid path
        XCTAssertThrowsError(try JSONPatch(jsonPatchString))
    }
    
    func testIfAdditionalElementsAreIgnored() {
        let jsonPatchString = """
        {"op": "test", "path": "/a/b/c", "value": "foo", "additionalParameter": "foo"}
        """
        do {
            let jsonPatch = try JSONPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].type, JSONPatchOperation.OperationType.test)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testIfElementsNotNecessaryForOperationAreIgnored() {
        let jsonPatchString = """
        {"op": "remove", "path": "/a/b/c", "value": "foo", "additionalParameter": "foo"}
        """
        do {
            let jsonPatch = try JSONPatch(jsonPatchString)
            XCTAssertEqual(jsonPatch.operations.count, 1)
            XCTAssertEqual(jsonPatch.operations[0].type, JSONPatchOperation.OperationType.remove)
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
            let jsonPatch0 = try JSONPatch(jsonPatchString0)
            let jsonPatch1 = try JSONPatch(jsonPatchString1)
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
            let jsonPatch0 = try JSONPatch(jsonPatchString0)
            let jsonPatch1 = try JSONPatch(jsonPatchString1)
            XCTAssertNotEqual(jsonPatch0, jsonPatch1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
