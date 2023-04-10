//
//  PostsView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import SwiftUI

struct PostsView: View {
    @State private var createNewPost: Bool = false
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .hAlign(.center)
            .vAlign(.center)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    createNewPost.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .padding(13)
                        .background(.gray.opacity(0.5), in: Circle())
                }
                .padding(15)
            }
            .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPostView { post in
                    
                }
            }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
