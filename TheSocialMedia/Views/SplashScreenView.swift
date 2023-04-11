//
//  SplashScreenView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 11/04/23.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive: Bool = false
    @State private var size = 1.0
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                ZStack {
                    Image("tsm_icon")
                        .resizable()
                        .ignoresSafeArea()
                    
                    Text("Version 1.0.0")
                        .font(.footnote)
                        .fontWidth(.condensed)
                        .foregroundColor(.white)
                        .vAlign(.bottom)
                        .hAlign(.trailing)
                        .padding()
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        self.size = 1.2
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
