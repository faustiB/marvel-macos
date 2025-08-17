//
//  MarvelModel.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import Foundation

struct MarvelResponse<T: Codable>: Codable {
  let code: Int
  let status: String
  let copyright: String
  let attributionText: String
  let attributionHTML: String
  let etag: String
  let data: MarvelDataContainer<T>
}

struct MarvelDataContainer<T: Codable>: Codable {
  let offset: Int
  let limit: Int
  let total: Int
  let count: Int
  let results: [T]
}
