//
//  APIManager.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation
import CryptoKit

protocol APIManagerProtocol {
  /// Sends a request to a given endpoint with optional parameters and decodes the response.
  ///
  /// - Parameters:
  ///   - endpoint: The API endpoint (relative path) to call.
  ///   - parameters: Optional query parameters to include in the request.
  ///   - responseType: The expected `Codable` response type.
  /// - Returns: A decoded object of type `T`.
  /// - Throws: An error if the request fails, the response is invalid, or decoding fails.
  func request<T: Codable>(endpoint: String, parameters: [String: String]?, responseType: T.Type) async throws -> T
}

/// A concrete implementation of `APIManagerProtocol` for communicating with the Marvel Comics API.
///
/// `APIManager` handles authentication, builds requests, and decodes JSON responses  from the Marvel API.
final class APIManager: APIManagerProtocol {
  /// The URL session used for making network requests.
  private let session: URLSession
  
  /// The base URL of the Marvel API.
  private let baseURL = URL(string: "https://gateway.marvel.com/v1/public")
  
  /// Creates a new APIManager.
  ///
  /// - Parameter session: A `URLSession` instance. Defaults to `.shared`.
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  /// Sends a request to the Marvel API and decodes the response into the specified type.
  ///
  /// - Parameters:
  ///   - endpoint: The API endpoint (relative path) to call.
  ///   - parameters: Optional query parameters.
  ///   - responseType: The expected `Codable` response type.
  /// - Returns: A decoded object of type `T`.
  /// - Throws: An `APIError` if the request, response, or decoding fails.
  func request<T: Codable>(endpoint: String, parameters: [String: String]? = nil, responseType: T.Type) async throws -> T {
    let url = try buildURL(endpoint: endpoint, parameters: parameters)
    let (data, response) = try await session.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }
    
    guard 200...299 ~= httpResponse.statusCode else {
      throw APIError.httpError(httpResponse.statusCode)
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    } catch {
      throw APIError.decodingError(error)
    }
  }
  
  /// Builds a full `URL` for a given API endpoint, including authentication and custom query parameters.
  ///
  /// - Parameters:
  ///   - endpoint: The API endpoint path (relative).
  ///   - parameters: Optional query parameters to add.
  /// - Returns: A fully constructed `URL` ready for a request.
  /// - Throws: `APIError.invalidURL` if the URL cannot be built.
  private func buildURL(endpoint: String, parameters: [String: String]?) throws -> URL {
    guard var components = URLComponents(url: baseURL?.appendingPathComponent(endpoint) ?? URL(fileURLWithPath: ""), resolvingAgainstBaseURL: true) else {
      throw APIError.invalidURL
    }
    
    // Add Marvel API authentication parameters
    let authParams = generateAuthParameters()
    var queryItems = authParams.map { URLQueryItem(name: $0.key, value: $0.value) }
    
    // Add custom parameters
    if let parameters = parameters {
      queryItems.append(contentsOf: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })
    }
    
    components.queryItems = queryItems
    
    guard let url = components.url else {
      throw APIError.invalidURL
    }
    
    return url
  }
  
  /// Generates the authentication parameters required by the Marvel API.
  ///
  /// Includes a timestamp, public key, and MD5 hash of timestamp + private key + public key.
  /// - Returns: A dictionary of authentication query parameters.
  private func generateAuthParameters() -> [String: String] {
    let timestamp = String(Date().timeIntervalSince1970)
    let hash = generateHash(timestamp: timestamp)
    let publicKey = getSecret(key: "MARVEL_PUBLIC_KEY")

    return [
      "ts": timestamp,
      "apikey": publicKey,
      "hash": hash
    ]
  }
  
  /// Generates the MD5 authentication hash required by the Marvel API.
  ///
  /// - Parameter timestamp: The timestamp string used for authentication.
  /// - Returns: A lowercase hexadecimal MD5 hash string.
  private func generateHash(timestamp: String) -> String {
    let publicKey = getSecret(key: "MARVEL_PUBLIC_KEY")
    let privateKey = getSecret(key: "MARVEL_PRIVATE_KEY")
    let input = timestamp + privateKey + publicKey
    let inputData = Data(input.utf8)
    let hashed = Insecure.MD5.hash(data: inputData)
    return hashed.map { String(format: "%02hhx", $0) }.joined()
  }
  
  /// Retrieves a secret value (e.g., API key) from the app's Info.plist.
  ///
  /// - Parameter key: The key for the secret value.
  /// - Returns: The string value for the given key.
  /// - Note: Will crash with `fatalError` if the secret is missing.
  private func getSecret(key: String) -> String {
    guard let value = Bundle.main.infoDictionary?[key] as? String else {
      fatalError("Secret not found. Add it to your local Keys.xcconfig")
    }
    return value
  }
  
  /// Defines errors that can occur during API requests.
  enum APIError: Error, LocalizedError {
    /// The URL could not be constructed.
    case invalidURL
    /// The response was not a valid HTTP response.
    case invalidResponse
    /// The server returned a non-2xx HTTP status code.
    case httpError(Int)
    /// The response could not be decoded into the expected type.
    case decodingError(Error)
    
    /// A human-readable description of the error.
    var errorDescription: String? {
      switch self {
      case .invalidURL:
        return "Invalid URL"
      case .invalidResponse:
        return "Invalid response"
      case .httpError(let code):
        return "HTTP Error: \(code)"
      case .decodingError(let error):
        return "Decoding error: \(error.localizedDescription)"
      }
    }
  }
}
