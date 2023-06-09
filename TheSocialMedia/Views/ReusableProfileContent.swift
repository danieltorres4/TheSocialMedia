//
//  ReusableProfileContent.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 04/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    @State var showWebView = false
    @State private var fetchdPosts: [Post] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack {
                HStack(spacing: 12) {
                    WebImage(url: user.userProfileURL).placeholder {
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(4)
                        
                        if let bioLink = URL(string: user.userBioLink) {
                            /*
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                             */
                            Button("\(user.userBioLink)") {
                                showWebView = true
                            }
                            .sheet(isPresented: $showWebView) {
                                WebView(url: user.userBioLink)
                            }
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("All Posts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
                
                ReusablePostsView(basedOnUID: true, uid: user.userID, posts: $fetchdPosts)
            }
            .padding(15)
        }
    }
}


