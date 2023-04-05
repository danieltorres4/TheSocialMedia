//
//  ContentView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 03/04/23.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView {
            Text("Recent Posts")
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Posts")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(.accentColor)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
