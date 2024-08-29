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
    @available(iOS 13.0.0, *)
    func testHeadersAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && hasHeaderNamed("Authorization", value: "Bearer 4U7H-70K3N")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
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
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && hasHeaderNamed("Authorization", value: "Bearer 4U7H-70K3N")) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
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
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    @available(iOS 13.0.0, *)
    func testGetAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
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
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET()) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource")

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    func testGetWithParamsAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && containsQueryParams(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
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
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodGET() && containsQueryParams(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", parameters: ["key": "value"])

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
    @available(iOS 13.0.0, *)
    func testPostAsyncEmptyResponse() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        let response: SNResponse<SNEmpty> = await network.request(request)
        
        XCTAssertEqual(response.status, 204)
        
        HTTPStubs.removeStub(stubbed)
    }

    func testPostEmptyResponse() {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: [:], statusCode: 204, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        network.request(request) { response in
            guard let object: SNEmpty = try? response.result.get() else {
                XCTFail("Wrong result")
                return
            }
            
            XCTAssertEqual(response.status, 200)
        }
        
        HTTPStubs.removeStub(stubbed)
    }

    func testPostWithResponseAsync() async {
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST() && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
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
        let stubbed = stub(condition: isPath("/path/to/resource") && isMethodPOST()  && hasJsonBody(["key": "value"])) { request in
            return HTTPStubsResponse(jsonObject: ["data": "correct"], statusCode: 200, headers: nil)
        }
        
        let network = SimpleNetwork(base: URL(string: "https://test.citibox.com")!)
        let request = SNRequest(path: "path/to/resource", method: .post, parameters: ["key": "value"])

        network.request(request) { response in
            if let object: MockDataModel = try? response.result.get() {
                XCTAssertEqual(object.data, "correct")
            } else {
                XCTFail("Wrong result")
            }
            
            XCTAssertEqual(response.status, 200)
        }
        
        HTTPStubs.removeStub(stubbed)
    }
    
}
