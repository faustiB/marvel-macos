//
//  ComicsViewModel.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation
class ComicsViewModel: ObservableObject {
  @Published var comics: [Comic] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  private let interactor: ComicsInteractorProtocol
  
  init(interactor: ComicsInteractorProtocol = ComicsInteractor()) {
    self.interactor = interactor
  }
  
  @MainActor
  func loadComics() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let response = try await interactor.fetchComics(limit: 20, offset: 0)
      comics = response.data.results
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
}
