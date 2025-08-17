//
//  ComicsViewModel.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

/// A view model responsible for managing the state and data of the comics view.
///
/// `ComicsViewModel` fetches comics using a `ComicsInteractorProtocol`, exposes loading and error states, and provides data binding for SwiftUI views.
class ComicsViewModel: ObservableObject {
  
  /// The list of comics currently loaded from the Marvel API.
  @Published var comics: [Comic] = []
  
  /// A Boolean value that indicates whether data is currently being loaded.
  @Published var isLoading = false
  
  /// An optional error message to display if loading fails.
  @Published var errorMessage: String?
  
  /// The interactor responsible for fetching comics data.
  private let interactor: ComicsInteractorProtocol
  
  /// Creates a new instance of `ComicsViewModel`.
  ///
  /// - Parameter interactor: The comics interactor used to fetch data. Defaults to `ComicsInteractor`.
  init(interactor: ComicsInteractorProtocol = ComicsInteractor()) {
    self.interactor = interactor
  }

  /// Loads comics asynchronously from the Marvel API.
  ///
  /// This method:
  /// - Sets `isLoading` to `true` while fetching.
  /// - Clears any previous `errorMessage`.
  /// - Updates the `comics` array on success.
  /// - Updates `errorMessage` if an error occurs.
  /// - Resets `isLoading` to `false` when finished.
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
