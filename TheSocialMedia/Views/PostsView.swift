//
//  PostsView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import SwiftUI

struct PostsView: View {
    @State private var createNewPost: Bool = false
    @State private var recentPosts: [Post] = []
    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentPosts)
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
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUsersView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.accentColor)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("Recent Posts")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPostView { post in
                recentPosts.insert(post, at: 0)
            }
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
