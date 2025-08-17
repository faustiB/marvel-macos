//
//  AppDelegate.swift
//  marvel-comics
//
//  Created by Faozi Bouybaouene on 17/8/25.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
  private let systemBarHelper = SystemBarHelper()
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    let rootView = AnyView(ContentView())
    systemBarHelper.setupBarItem(rootView: rootView)
    systemBarHelper.showWindow()
  }
}
