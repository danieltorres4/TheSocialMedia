//
//  ContentView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 04/04/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        /// Based on the log status
        if logStatus {
            MainView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
