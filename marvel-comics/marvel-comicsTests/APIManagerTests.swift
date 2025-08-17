//
//  APIManagerTests.swift
//  marvel-comicsTests
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import XCTest
@testable import marvel_comics
import XCTest
import Foundation

/// Unit tests for `APIManager`.
///
/// `APIManagerTests` verifies the behavior of API requests, including:
/// - Correct URL construction with authentication parameters.
/// - Handling of HTTP errors.
/// - Decoding of successful responses.
/// - Handling of decoding errors.
final class APIManagerTests: XCTestCase {
  
  /// A stub `URLProtocol` that intercepts network requests for testing.
  ///
  /// Allows providing a custom response for any URL request.
  final class StubURLProtocol: URLProtocol {
    
    /// A closure that returns a tuple of HTTPURLResponse and Data for a given URLRequest.
    static var responseHandler: ((URLRequest) -> (HTTPURLResponse, Data))?
    
    /// Determines whether this protocol can handle the given request. Always `true`.
    override class func canInit(with request: URLRequest) -> Bool { true }
    
    /// Returns the canonical form of the request. Here, it returns the request unchanged.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    /// Starts loading the request, using the `responseHandler` closure.
    override func startLoading() {
      guard let handler = StubURLProtocol.responseHandler else {
        client?.urlProtocol(self, didFailWithError: NSError(domain: "no_handler", code: -1))
        return
      }
      let (response, data) = handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    }
    
    /// Stops loading the request. No operation needed for the stub.
    override func stopLoading() {}
  }
  
  /// Creates a `URLSession` configured to use the `StubURLProtocol`.
  private func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
  }
  
  /// Tests that `APIManager` builds URLs with the correct authentication parameters.
  func test_request_buildsURLWithAuthParams() async throws {
    let session = makeSession()
    let sut = APIManager(session: session)
    
    var capturedURL: URL?
    
    StubURLProtocol.responseHandler = { request in
      capturedURL = request.url
      let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      let json = """
      {"code":200,"status":"Ok","copyright":"","attributionText":"","attributionHTML":"","etag":"e","data":{"offset":0,"limit":0,"total":0,"count":0,"results":[]}}
      """.data(using: .utf8)!
      return (response, json)
    }
    
    _ = try await sut.request(endpoint: "/comics", parameters: nil, responseType: MarvelResponse<Comic>.self)
    
    let urlString = capturedURL?.absoluteString ?? ""
    XCTAssertTrue(urlString.contains("/v1/public/comics"))
    XCTAssertTrue(urlString.contains("ts="))
    XCTAssertTrue(urlString.contains("apikey="))
    XCTAssertTrue(urlString.contains("hash="))
  }
  
  /// Tests that `APIManager` correctly handles HTTP errors (e.g., 404).
  func test_request_handlesHTTPError() async {
    let session = makeSession()
    let sut = APIManager(session: session)
    
    StubURLProtocol.responseHandler = { request in
      let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
      return (response, Data())
    }
    
    do {
      _ = try await sut.request(endpoint: "/comics", parameters: nil, responseType: MarvelResponse<Comic>.self)
      XCTFail("Expected HTTP error")
    } catch let error as APIManager.APIError {
      if case .httpError(404) = error { /* ok */ } else { XCTFail("Wrong error: \(error)") }
    } catch {
      XCTFail("Wrong error type: \(error)")
    }
  }
  
  /// Tests that `APIManager` decodes successful responses correctly.
  func test_request_decodesSuccess() async throws {
    let session = makeSession()
    let sut = APIManager(session: session)
    
    StubURLProtocol.responseHandler = { request in
      let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      let json = """
      {"code":200,"status":"Ok","copyright":"","attributionText":"","attributionHTML":"","etag":"e","data":{"offset":0,"limit":1,"total":1,"count":1,"results":[{"id":1,"digitalId":0,"title":"Test","issueNumber":1.0,"variantDescription":"","description":null,"isbn":"","pageCount":1,"resourceURI":"","urls":[],"dates":[],"prices":[],"creators":{"available":0,"collectionURI":"","items":[],"returned":0}}]}}
      """.data(using: .utf8)!
      return (response, json)
    }
    
    let res: MarvelResponse<Comic> = try await sut.request(endpoint: "/comics", parameters: nil, responseType: MarvelResponse<Comic>.self)
    XCTAssertEqual(res.data.results.count, 1)
    XCTAssertEqual(res.data.results.first?.id, 1)
  }
  
  /// Tests that `APIManager` throws a decoding error for malformed JSON.
  func test_request_decodingError() async {
    let session = makeSession()
    let sut = APIManager(session: session)
    
    StubURLProtocol.responseHandler = { request in
      let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      let malformed = Data("{".utf8) // invalid JSON
      return (response, malformed)
    }
    
    do {
      _ = try await sut.request(endpoint: "/comics", parameters: nil, responseType: MarvelResponse<Comic>.self)
      XCTFail("Expected decoding error")
    } catch let error as APIManager.APIError {
      if case .decodingError = error { /* ok */ } else { XCTFail("Wrong error: \(error)") }
    } catch {
      XCTFail("Wrong error type: \(error)")
    }
  }
}
