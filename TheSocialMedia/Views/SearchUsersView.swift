//
//  SearchUsersView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 12/04/23.
//

import SwiftUI
import FirebaseFirestore

struct SearchUsersView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .onSubmit(of: .search, {
            Task {
                await searchUsers()
            }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
    
    func searchUsers() async {
        do {
            /// There is no way to usea a kind of "search contains" in Firebase, so we must use greater or less than
            /// in order to find results in the document
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
    }
}
