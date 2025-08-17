//
//  ComicInteractor.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation

protocol ComicsInteractorProtocol {
  func fetchComics(limit: Int, offset: Int) async throws -> MarvelResponse<Comic>
}

// MARK: - Comics Interactor
class ComicsInteractor: ComicsInteractorProtocol {
  private let apiManager: APIManagerProtocol
  
  init(apiManager: APIManagerProtocol = APIManager()) {
    self.apiManager = apiManager
  }
  
  func fetchComics(limit: Int = 20, offset: Int = 0) async throws -> MarvelResponse<Comic> {
    let parameters = [
      "limit": String(limit),
      "offset": String(offset),
      "orderBy": "-modified"
    ]
    
    return try await apiManager.request(
      endpoint: "/comics",
      parameters: nil,
      responseType: MarvelResponse<Comic>.self
    )
  }
}
