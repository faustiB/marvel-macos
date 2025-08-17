//
//  ComicInteractor.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation

protocol ComicsInteractorProtocol {
  /// Fetches a list of comics from the Marvel API.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of comics to return. Default is 20.
  ///   - offset: The number of comics to skip before starting to return results. Default is 0.
  /// - Returns: A `MarvelResponse` containing an array of `Comic` objects.
  /// - Throws: An error if the network request or decoding fails.
  func fetchComics(limit: Int, offset: Int) async throws -> MarvelResponse<Comic>
}

// MARK: - Comics Interactor


/// The concrete implementation of `ComicsInteractorProtocol`.
///
/// `ComicsInteractor` uses `APIManagerProtocol` to communicate with the Marvel API and retrieve comics data.
class ComicsInteractor: ComicsInteractorProtocol {
  /// The API manager used to perform requests.
  private let apiManager: APIManagerProtocol
  
  /// Creates a new instance of `ComicsInteractor`.
  ///
  /// - Parameter apiManager: The API manager to use. Defaults to a concrete `APIManager`.
  init(apiManager: APIManagerProtocol = APIManager()) {
    self.apiManager = apiManager
  }
  
  /// Fetches a list of comics from the Marvel API.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of comics to return. Default is 20.
  ///   - offset: The number of comics to skip before starting to return results. Default is 0.
  /// - Returns: A `MarvelResponse` containing an array of `Comic` objects.
  /// - Throws: An error if the request fails or the response cannot be decoded.
  func fetchComics(limit: Int = 20, offset: Int = 0) async throws -> MarvelResponse<Comic> {
    return try await apiManager.request(
      endpoint: "/comics",
      parameters: nil,
      responseType: MarvelResponse<Comic>.self
    )
  }
}
