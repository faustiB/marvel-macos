//
//  ContentView.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var comicsViewModel = ComicsViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
          Task {
            await comicsViewModel.loadComics()
          }
        }
    }
}

#Preview {
    ContentView()
}
