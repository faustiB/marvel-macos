//
//  SystemBarHelper.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import AppKit
import SwiftUI

/// A helper class that manages the system status bar item and its associated window.
///
/// `SystemBarHelper` creates a status bar icon, attaches a SwiftUI root view,
/// and manages the lifecycle of the window displayed when the icon is clicked.
final class SystemBarHelper: NSObject, NSWindowDelegate {
  private var barItem: NSStatusItem?
  private var window: NSWindow?
  private var rootViewController: NSHostingController<AnyView>?
  
  /// Sets up the system status bar item with an icon and associates it with a root SwiftUI view.
  ///
  /// - Parameter rootView: The SwiftUI view to be embedded inside the window.
  func setupBarItem(rootView: AnyView) {
    let systemBar = NSStatusBar.system
    let barItem = systemBar.statusItem(withLength: NSStatusItem.variableLength)
    
    barItem.button?.image = NSImage(systemSymbolName: "books.vertical.fill", accessibilityDescription: "Marvel for AppLivery")
    barItem.button?.action = #selector(openWindow)
    barItem.button?.target = self
    
    self.barItem = barItem
    rootViewController = NSHostingController(rootView: rootView)
  }
  
  /// Displays the app window, creating it if necessary, and brings it to the foreground.
  ///
  /// This method centers the window, makes it key, and activates the app even if
  /// another app is currently active.
  func showWindow() {
    createWindowIfNeeded()
    
    guard let window = self.window else { return }
    
    window.center()
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  //  MARK: - Button actions
  
  /// Toggles the visibility of the app window when the status bar button is clicked.
  ///
  /// If the window is visible, it hides it. Otherwise, it creates and shows it.
  @objc func openWindow() {
    createWindowIfNeeded()
    
    guard let window = self.window else { return }
    
    if window.isVisible {
      // remove window if it is already visible
      window.orderOut(self)
    } else {
      showWindow()
    }
  }
  
  //  MARK: -  Helper functions
  
  /// Creates a new app window and assigns the root SwiftUI view to it.
  ///
  /// The window is configured with a title, standard style masks, and sets this
  /// class as its delegate. Use `showWindow()` to present it.
  private func createWindow() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered, defer: false
    )
    window.title = "Marvel Comics for Applivery"
    window.isReleasedWhenClosed = false
    window.delegate = self
    
    guard let rootViewController = self.rootViewController else { return }
    
    window.contentView = rootViewController.view
    
    self.window = window
  }

  /// Ensures the window exists by creating it if it hasn't been initialized yet.
  ///
  /// This method is called before showing or toggling the window to avoid
  /// unnecessary re-creation.
  private func createWindowIfNeeded() {
    if self.window == nil {
      createWindow()
    }
  }
  
  //  MARK: - NSWindowDelegate
  
  /// Intercept the close action to hide the window instead of fully closing it.
  /// This keeps the app running in the status bar and allows quick reopen.
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    sender.orderOut(self)
    return false
  }
  
}
