//
//  ComicsViewModelTests.swift
//  marvel-comicsTests
//
//  Created by Faozi Bouybaouene on 17/8/25.
//
import XCTest
@testable import marvel_comics

/// Unit tests for `ComicsViewModel`.
///
/// Validates that the view model correctly updates its state when loading comics,
/// handling both success and error scenarios.
final class ComicsViewModelTests: XCTestCase {
  
  /// Simple test error type to simulate API failures.
  private struct TestError: Error {}
  
  /// Mock implementation of `ComicsInteractorProtocol` to control responses for testing.
  final class MockComicsInteractor: ComicsInteractorProtocol {
    /// Determines whether the mock returns success or failure.
    var result: Result<MarvelResponse<Comic>, Error> = .failure(TestError())
    
    /// Mock fetchComics method, returning either a predefined response or throwing an error.
    func fetchComics(limit: Int, offset: Int) async throws -> MarvelResponse<Comic> {
      switch result {
      case .success(let response):
        return response
      case .failure(let error):
        throw error
      }
    }
  }
  
  /// Helper method to create a `MarvelResponse` with the provided comics.
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
  
  /// Tests that `loadComics` successfully updates the view model state when the API returns comics.
  func test_loadComics_success_updatesState() async {
    let mock = MockComicsInteractor()
    let comic = Comic(
      id: 1,
      digitalId: 0,
      title: "Test Comic",
      issueNumber: 1.0,
      variantDescription: "",
      description: nil,
      isbn: "",
      pageCount: 1,
      resourceURI: "",
      urls: [],
      dates: [],
      prices: [],
      creators: CreatorList(available: 0, collectionURI: "", items: [], returned: 0)
    )
    mock.result = .success(makeResponse(comics: [comic]))
    
    let viewModel = ComicsViewModel(interactor: mock)
    
    await viewModel.loadComics()
    
    XCTAssertFalse(viewModel.isLoading)             // Loading should be false after completion
    XCTAssertEqual(viewModel.comics.count, 1)      // Comics array should contain one comic
    XCTAssertNil(viewModel.errorMessage)           // No error should be set
  }
  
  /// Tests that `loadComics` sets an error message when the API call fails.
  func test_loadComics_failure_setsError() async {
    let mock = MockComicsInteractor()
    mock.result = .failure(TestError())
    
    let viewModel = ComicsViewModel(interactor: mock)
    
    await viewModel.loadComics()
    
    XCTAssertFalse(viewModel.isLoading)            // Loading should be false after failure
    XCTAssertNotNil(viewModel.errorMessage)        // Error message should be set
  }
}
