//
//  ReusablePostsView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostsView: View {
    @Binding var posts: [Post]
    @State var isFetching: Bool = true
    
    /// Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        Text("Cannot Found Posts 😓")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.top, 30)
                    } else {
                        /// Displaying all the posts
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task {
            /// Fetching only once
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
    }
    
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                /// updating a post
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].clappedIDs = updatedPost.clappedIDs
                }
            } onDelete: {
                /// Removing a post from the array
                withAnimation(.easeOut(duration: 0.25)) {
                    posts.removeAll { post.id == $0.id}
                }
            }
            .onAppear {
                /// When the last posts has been appeared, we'll fetch a new one if it exists
                if post.id == posts.last?.id && paginationDoc != nil {
                    /// Checking that pagination isn't nil to ensure that there are posts to fetch
                    Task {
                        await fetchPosts()
                    }
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    func fetchPosts() async {
        do {
            var query: Query!
            
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate", descending: true).start(afterDocument: paginationDoc).limit(to: 5)
            } else {
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate", descending: true).limit(to: 5)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                /// Saving the last fetched document in order to be used for pagination
                paginationDoc = docs.documents.last
                isFetching = false
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
