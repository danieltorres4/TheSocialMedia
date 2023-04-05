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
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Your Posts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
            .padding(15)
        }
    }
}


