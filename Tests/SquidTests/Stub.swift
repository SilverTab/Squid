//
//  Stub.swift
//  Squid
//
//  Created by Oliver Borchert on 10/6/19.
//

import Foundation
import UIKit
import OHHTTPStubsCore
import OHHTTPStubsSwift
@testable import Squid

class StubFactory {
    
    internal static let shared = StubFactory()
    @Locked private var requestIsThrottled = true
    
    private init() { }
    
    func usersGet() {
        let descriptor = stub(
            condition: isHost("squid.borchero.com") && isMethodGET() && isPath("/users")
        ) { _ -> OHHTTPStubsResponse in
            let path = OHPathForFile("users.json", type(of: self))!
            return fixture(
                filePath: path,
                status: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        descriptor.name = "Users GET Stub"
    }
    
    func usersNameGet() {
        let descriptor = stub(
            condition: isHost("squid.borchero.com") && isMethodGET() && isPath("/users")
                && containsQueryParams(["lastname": "Doe"])
        ) { _ -> OHHTTPStubsResponse in
            let path = OHPathForFile("users.json", type(of: self))!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let json = try! JSONSerialization.jsonObject(
                with: data, options: []
            ) as! [[String: Any]]
            let result = json.filter { $0["lastname"] as! String == "Doe" }

            return .init(
                data: try! JSONSerialization.data(withJSONObject: result, options: []),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        descriptor.name = "Users Name GET Stub"
    }
    
    func usersPost() {
        let descriptor = stub(condition: { request -> Bool in
            let data = request.ohhttpStubs_httpBody!
            let json = try! JSONSerialization.jsonObject(
                with: data, options: []
            ) as! [String: String]
            
            return request.url?.host == "squid.borchero.com"
                && request.url?.path == "/users"
                && request.httpMethod == "POST"
                && Set(json.keys) == ["firstname", "lastname"]
                && json["firstname"] == "John"
                && json["lastname"] == "Doe"
        }) { request -> OHHTTPStubsResponse in
            let data = request.ohhttpStubs_httpBody!
            let json = try! JSONSerialization.jsonObject(
                with: data, options: []
            ) as! [String: String]
            
            let responseJson = [
                "firstname": json["firstname"]!,
                "lastname": json["lastname"]!,
                "id": 2
            ] as [String : Any]
            let responseData = try! JSONSerialization.data(
                withJSONObject: responseJson, options: []
            )
            
            return .init(
                data: responseData,
                statusCode: 201,
                headers: ["Content-Type": "application/json"]
            )
        }
        descriptor.name = "Users POST Stub"
    }
    
    func usersImagePost() {
        let descriptor = stub(condition: { request -> Bool in
            let data = request.ohhttpStubs_httpBody!
            let originalImage = UIImage(
                contentsOfFile: Bundle(for: type(of: self)).path(forResource: "cat", ofType: "jpg")!
            )!
            let originalData = originalImage.jpegData(compressionQuality: 1)!
            
            return request.url?.host == "squid.borchero.com"
                && request.url?.path == "/users/0/image"
                && request.httpMethod == "POST"
                && request.allHTTPHeaderFields?["Content-Type"] == "image/jpeg"
                && request.allHTTPHeaderFields?["Content-Length"] == "30962"
                && data.count == 30962
                && data == originalData
        }) { _ -> OHHTTPStubsResponse in
            return .init(data: Data(), statusCode: 201, headers: [:])
        }
        descriptor.name = "Users Image POST Stub"
    }
    
    func enableThrottling(_ throttle: Bool) {
        self._requestIsThrottled.sync { $0 = throttle }
    }
    
    func throttlingRequest() {
        let descriptor = stub(
            condition: isHost("squid.borchero.com") && isMethodGET() && isPath("/throttle")
        ) { _ -> OHHTTPStubsResponse in
            if self._requestIsThrottled.sync({ $0 }) {
                return .init(data: Data(), statusCode: 429, headers: [:])
            }
            return .init(data: Data(), statusCode: 200, headers: [:])
        }
        descriptor.name = "Throttling Stub"
    }
    
    func authorizationRequest() {
        let descriptor = stub(
            condition: isHost("squid.borchero.com") && isMethodPOST() && isPath("/login")
                && hasHeaderNamed("Authorization", value: "letmepass")
                && hasHeaderNamed("Content-Type", value: "application/json")
                && hasHeaderNamed("Accept-Language", value: "en")
        ) { _ -> OHHTTPStubsResponse in
            return .init(data: Data(), statusCode: 200, headers: [:])
        }
        descriptor.name = "Authorization Stub"
    }
}