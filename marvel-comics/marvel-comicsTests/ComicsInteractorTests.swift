//
//  ComicsInteractorTests.swift
//  marvel-comicsTests
//
//  Created by Faozi Bouybaouene on 17/8/25.
//
import XCTest
@testable import marvel_comics

/// Unit tests for `ComicsInteractor`.
///
/// Validates that the interactor correctly calls the API manager and handles both success
/// and error cases when fetching comics.
final class ComicsInteractorTests: XCTestCase {
  
  /// Mock implementation of `APIManagerProtocol` used to capture requests and return
  /// controlled responses for testing.
  final class MockAPIManager: APIManagerProtocol {
    
    /// Structure to capture the endpoint and parameters of a request.
    struct CapturedRequest {
      let endpoint: String
      let parameters: [String: String]?
    }
    
    /// Stores the last captured request.
    var captured: CapturedRequest?
    
    /// Determines what result the mock will return when `request` is called.
    var result: Result<Any, Error> = .failure(NSError(domain: "", code: -1))
    
    /// Mock implementation of the API request method.
    ///
    /// Captures the request details and either returns a predefined response or throws an error.
    func request<T>(endpoint: String, parameters: [String : String]?, responseType: T.Type) async throws -> T where T : Decodable, T : Encodable {
      captured = CapturedRequest(endpoint: endpoint, parameters: parameters)
      switch result {
      case .success(let value):
        guard let typed = value as? T else { throw NSError(domain: "type_mismatch", code: -1) }
        return typed
      case .failure(let error):
        throw error
      }
    }
  }
  
  /// Helper method to create a `MarvelResponse` containing the given comics.
  private func makeResponse(comics: [Comic]) -> MarvelResponse<Comic> {
    return MarvelResponse(
      code: 200,
      status: "Ok",
      copyright: "",
      attributionText: "",
      attributionHTML: "",
      etag: "etag",
      data: MarvelDataContainer(
        offset: 0,
        limit: comics.count,
        total: comics.count,
        count: comics.count,
        results: comics
      )
    )
  }
  
  /// Tests that `fetchComics` calls the API with the correct endpoint and returns the expected response.
  func test_fetchComics_callsAPIWithCorrectEndpoint_andReturnsResponse() async throws {
    let mockAPI = MockAPIManager()
    let interactor = ComicsInteractor(apiManager: mockAPI)
    let response = makeResponse(comics: [])
    mockAPI.result = .success(response)
    
    let result: MarvelResponse<Comic> = try await interactor.fetchComics(limit: 10, offset: 5)
    
    XCTAssertEqual(mockAPI.captured?.endpoint, "/comics") // Verify correct endpoint
    XCTAssertEqual(result.data.results.count, 0) // Verify returned results
  }
  
  /// Tests that `fetchComics` propagates errors from the API manager.
  func test_fetchComics_propagatesError() async {
    let mockAPI = MockAPIManager()
    let interactor = ComicsInteractor(apiManager: mockAPI)
    mockAPI.result = .failure(APIManager.APIError.invalidResponse)
    
    do {
      _ = try await interactor.fetchComics(limit: 10, offset: 0)
      XCTFail("Expected error") // Should not succeed
    } catch {
      // Expected path: error is propagated correctly
    }
  }
}
