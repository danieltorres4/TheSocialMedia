//
//  ProfileView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 04/04/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    @State private var myProfile: User?
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            self.myProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Log out") {
                            logoutUser()
                        }
                        
                        Button("Delete Account", role: .destructive) {
                            deleteUser()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
        .task {
            if myProfile != nil { return }
            
            await fetchUserData()
        }
    }
    
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else { return }
        
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    func logoutUser() {
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    func deleteUser() {
        isLoading = true
        
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                
                /// Deleting the profile image, user's document and Auth account
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                
                try await Auth.auth().currentUser?.delete()
                
                logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
