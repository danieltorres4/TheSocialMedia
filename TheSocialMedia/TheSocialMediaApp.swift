//
//  TheSocialMediaApp.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 03/04/23.
//

import SwiftUI
import Firebase

@main
struct TheSocialMediaApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
