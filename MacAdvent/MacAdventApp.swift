//
//  MacAdventApp.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 17/03/2025.
//

import SwiftUI

@main
struct MacAdventApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            // Add custom menu items here
            CommandMenu("My Menu") {
                Button("Menu Item 1") {
                    // Action for Menu Item 1
                    print("Menu Item 1 selected")
                }
                Button("Menu Item 2") {
                    // Action for Menu Item 2
                    print("Menu Item 2 selected")
                }
                // Add more menu items as needed
            }
        }
    }
}
