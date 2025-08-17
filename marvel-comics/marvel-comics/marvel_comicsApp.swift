//
//  marvel_comicsApp.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import SwiftUI

/// The main entry point of the Marvel Comics app for macOS.
///
/// This struct conforms to the `App` protocol and sets up the application lifecycle,
/// delegating to `AppDelegate` for additional configuration.
@main
struct marvel_comicsApp: App {
  /// The app delegate responsible for handling application-level events and setup.
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  /// The main scene of the app.
  ///
  /// Since this app primarily runs in the menu bar, the only declared scene is
  /// a hidden `Settings` scene with an `EmptyView`.
  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
