//
//  ComicListSheetView.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

struct ComicListSheetView: View {
  @Binding var selectedComic: Comic?
  var comic: Comic
  
  
  var body: some View {
    VStack(spacing: 16) {
      Text(comic.title)
        .bold()
      
      Text("Page count: \(comic.pageCount)")
        .font(.caption)
      
      Text("Creators: \(comic.creators.items.map { $0.name }.joined(separator: ", "))")
        .font(.caption)
      
      Text("On sale date: \(formatDate(comic.dates.first(where: { $0.type == "onsaleDate" })?.date))")
        .font(.caption)
      
      HStack(spacing: 2) {
        Text("URL:")
          .font(.caption)
        
        if let detailURL = comic.urls.first(where: { $0.type == "detail" })?.url,
           let url = URL(string: detailURL) {
          Link(detailURL, destination: url)
            .font(.caption)
        } else {
          Text("Unknown")
            .font(.caption)
        }
      }
      
      Spacer()
      
      Button {
        selectedComic = nil
      } label: {
        Text("Go back")
          .padding(16)
      }
      .shadow(radius: 0.5)
      
    }
  }
  
  private func formatDate(_ dateString: String?) -> String {
    guard let dateString = dateString else { return "Unknown" }
    
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: dateString) else { return dateString }
    
    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .long
    displayFormatter.timeStyle = .none
    
    return displayFormatter.string(from: date)
  }
}

