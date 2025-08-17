//
//  ComicsModel.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation

import Foundation

struct Comic: Codable, Identifiable {
  let id: Int
  let digitalId: Int
  let title: String
  let issueNumber: Double
  let variantDescription: String
  let description: String?
  let isbn: String
  let pageCount: Int
  let resourceURI: String
  let urls: [ComicURL]
  let dates: [ComicDate]
  let prices: [ComicPrice]
  let creators: CreatorList
}

struct ComicURL: Codable {
  let type: String
  let url: String
}

struct ComicDate: Codable {
  let type: String
  let date: String
}

struct ComicPrice: Codable {
  let type: String
  let price: Double
}

struct CreatorList: Codable {
  let available: Int
  let collectionURI: String
  let items: [CreatorSummary]
  let returned: Int
}

struct CreatorSummary: Codable {
  let resourceURI: String
  let name: String
  let role: String
}

struct CreatorGroup: Identifiable {
  let id = UUID()
  let creatorName: String
  let comics: [Comic]
}
