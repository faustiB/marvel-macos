//
//  ComicsListView.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

struct ComicsListView: View {
  @StateObject private var comicsViewModel = ComicsViewModel()
  
  var body: some View {
    VStack {
      if comicsViewModel.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else {
        List(comicsViewModel.comics, id: \.id) { comic in
          HStack {
            Text(comic.title)
              .font(.headline)
            
            Spacer()
            
            Text(String(comic.prices[0].price))
              .italic()
            
            Image(systemName: "chevron.right")
              .foregroundColor(.red)
          }
          .padding(16)
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
  }
}

#Preview {
  ComicsListView()
}
