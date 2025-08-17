//
//  AppDelegate.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import AppKit
import SwiftUI

/// The application delegate responsible for handling lifecycle events of the app.
///
/// `AppDelegate` configures the system status bar item and displays the main window
/// when the application finishes launching.
final class AppDelegate: NSObject, NSApplicationDelegate {
  
  /// A helper object that manages the system status bar item and the app's main window.
  private let systemBarHelper = SystemBarHelper()
  
  /// Called after the application has finished launching.
  ///
  /// This method:
  /// - Creates the root SwiftUI content view.
  /// - Attaches the view to the system status bar item via `SystemBarHelper`.
  /// - Shows the app window immediately after launch.
  ///
  /// - Parameter notification: A notification sent by the system when the app has launched.
  func applicationDidFinishLaunching(_ notification: Notification) {
    let rootView = AnyView(ContentView())
    systemBarHelper.setupBarItem(rootView: rootView)
    systemBarHelper.showWindow()
  }
}
