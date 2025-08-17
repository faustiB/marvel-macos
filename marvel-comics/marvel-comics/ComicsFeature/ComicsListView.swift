//
//  ComicsListView.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

struct ComicsListView: View {
  @StateObject private var comicsViewModel = ComicsViewModel()
  @State private var selectedComic: Comic? = nil
  
  var body: some View {
    VStack {
      if comicsViewModel.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else {
        List {
          ForEach(comicsViewModel.creatorGroups, id: \.id) { creatorGroup in
            Section {
              ForEach(creatorGroup.comics, id: \.id) { comic in
                Button {
                  selectedComic = comic
                } label: {
                  ComicListRowView(comic: comic)
                }
              }
            } header: {
              Text(creatorGroup.creatorName)
                .font(.headline)
                .fontWeight(.bold)
            }
          }
        }
        .listStyle(.bordered)
      }
    }
    .frame(minWidth: 480, minHeight: 480)
    .onAppear {
      Task {
        await comicsViewModel.loadComics()
      }
    }
    .sheet(item: $selectedComic) { comic in
      ComicListSheetView(selectedComic: $selectedComic, comic: comic)
        .padding()
    }
  }
}

struct ComicListRowView: View {
  var comic: Comic
  
  var body: some View {
    HStack {
      Text(comic.title)
        .font(.headline)
      
      Spacer()
      
      Text(String(comic.prices[0].price))
        .italic()
      
      Image(systemName: "chevron.right")
        .foregroundColor(.blue)
    }
    .padding(16)
  }
}


#Preview {
  ComicsListView()
}
