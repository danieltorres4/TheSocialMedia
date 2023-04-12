//
//  PostCardView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration? /// for live updates
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            /// Displaying a delete button of every personal post
            if post.userID == userUID {
                Menu {
                    Button("Delete Post", role: .destructive, action: { deletePost() })
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.accentColor)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            /// This will be added once
            if docListener == nil {
                guard let postID = post.id else { return }
                
                docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            /// Update document, fetching the updated document
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            /// Deleting document
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear {
            /// Removing listener `
            if let docListener {
                docListener.remove()
                self.docListener = nil
            }
        }
    }
    
    /// Interactions
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button {
                likeInteraction()
            } label: {
                Image(systemName: post.likedIDs.contains(userUID) ?  "hand.thumbsup.fill" : "hand.thumbsup")
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.accentColor)
            
            Button {
                clapInteraction()
            } label: {
                Image(systemName: post.clappedIDs.contains(userUID) ? "hands.clap.fill" : "hands.clap")
            }
            .padding(.leading, 25)
            Text("\(post.clappedIDs.count)")
                .font(.caption)
                .foregroundColor(.accentColor)
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 8)
    }
    
    func likeInteraction() {
        Task {
            guard let postID = post.id else { return }
            
            if post.likedIDs.contains(userUID) {
                /// removing the user ID
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                /// Adding a user to the liked array and removing the ID from the clapped array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "clappedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    func clapInteraction() {
        Task {
            guard let postID = post.id else { return }
            
            if post.clappedIDs.contains(userUID) {
                /// removing the user ID
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "clappedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                /// Adding a user to the liked array and removing the ID from the clapped array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "clappedIDs": FieldValue.arrayUnion([userUID]),
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    func deletePost() {
        Task {
            /// Deleting the image from firebase if there is one in the post
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                
                /// Deleting firestore document
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
