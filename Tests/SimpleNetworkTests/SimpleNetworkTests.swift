//
//  SimpleNetworkTests.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import SimpleNetwork

final class SimpleNetworkTests: XCTestCase {
    func testHeadersAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && hasHeaderNamed("Authorization", value: "Bearer 4U7H-70K3N")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(
            path: "path/to/resource",
            headers: [
                SNHeader.authorization(bearerToken: "4U7H-70K3N")
            ]
        )

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(response.headers["Content-Type"], "application/json")

        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "correct")
        } else {
            XCTFail("Wrong result")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testHeaders() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && hasHeaderNamed("Authorization", value: "Bearer 4U7H-70K3N")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(
            path: "path/to/resource",
            headers: [
                SNHeader.authorization(bearerToken: "4U7H-70K3N")
            ]
        )

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
            XCTAssertEqual(response.headers["Content-Type"], "application/json")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    func testGetAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource")

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)

        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "correct")
        } else {
            XCTFail("Wrong result")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testGet() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource")

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    func testGetWithParamsAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && containsQueryParams(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", parameters: ["key": "value"])

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)

        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "correct")
        } else {
            XCTFail("Wrong result")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testGetWithParams() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && containsQueryParams(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", parameters: ["key": "value"])

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    func testPostAsyncEmptyResponse() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        let response: SNResponse<SNEmpty> = await network.request(request)
        
        XCTAssertEqual(response.status, 204)
        
        HTTPStubs.removeStub(stubbed)
    }

    func testPostEmptyResponse() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        network.request(request) { response in
            guard let object: SNEmpty = try? response.result.get() else {
                XCTFail("Wrong result")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(response.status, 204)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }

    func testPostWithResponseAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)

        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "correct")
        } else {
            XCTFail("Wrong result")
        }
        
        HTTPStubs.removeStub(stubbed)
    }

    func testPostWithResponse() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST()  && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    // MARK: - DELETE Tests
    
    func testDeleteAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodDELETE()) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .delete)

        let response: SNResponse<SNEmpty> = await network.request(request)
        
        XCTAssertEqual(response.status, 204)
        XCTAssertNotNil(try? response.result.get())
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testDelete() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodDELETE()) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .delete)

        network.request(request) { (response: SNResponse<SNEmpty>) in
            XCTAssertEqual(response.status, 204)
            XCTAssertNotNil(try? response.result.get())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    // MARK: - PATCH Tests
    
    func testPatchAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPATCH() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "patched"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .patch, parameters: ["key": "value"])

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)

        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "patched")
        } else {
            XCTFail("Wrong result")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testPatch() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPATCH() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "patched"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .patch, parameters: ["key": "value"])

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "patched")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    // MARK: - HEAD Tests
    
    func testHeadAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodHEAD()) { request in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Length": "1024"])
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .head)

        let response: SNResponse<SNEmpty> = await network.request(request)
        
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(response.headers["Content-Length"], "1024")
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testHead() {
        let expectation = self.expectation(description: "Request completed")
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodHEAD()) { request in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Length": "1024"])
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .head)

        network.request(request) { (response: SNResponse<SNEmpty>) in
            XCTAssertEqual(response.status, 200)
            XCTAssertEqual(response.headers["Content-Length"], "1024")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        HTTPStubs.removeStub(stubbed)
    }
    
    // MARK: - Status Validation & Retry Tests
    
    func testInvalidStatusAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            return HTTPStubsResponse(jsonObject: ["error": "Not Found"], statusCode: 404, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource")

        let response: SNResponse<MockDataModel> = await network.request(request)
        
        XCTAssertEqual(response.status, 404)
        
        if case .failure(let error) = response.result {
            if case .invalidStatus(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Expected invalidStatus error, got \(error)")
            }
        } else {
            XCTFail("Expected failure result for 404 status")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testRetrySuccessAfterFailure() async {
        var requestCount = 0
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            requestCount += 1
            if requestCount == 1 {
                return HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
            }
            return HTTPStubsResponse(jsonObject: ["data": "success"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetworkManager(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource")

        let response: SNResponse<MockDataModel> = await network.request(request, retryCount: 2, retryDelay: 0.1)
        
        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(response.status, 200)
        
        if let object = try? response.result.get() {
            XCTAssertEqual(object.data, "success")
        } else {
            XCTFail("Expected success after retry")
        }
        
        HTTPStubs.removeStub(stubbed)
    }
}