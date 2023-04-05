//
//  LoginView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 03/04/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var createNewAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Sign in")
                .font(.system(.largeTitle))
                .fontWidth(.expanded)
                .bold()
                .hAlign(.leading)
            
            Text("Welcome back")
                .font(.title3)
                .fontWidth(.condensed)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                TextField("Password", text: $password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .border(1, .gray.opacity(0.5))
                
                Button("Forgot password?", action: {
                    resetPassword()
                })
                    .font(.callout)
                    .fontWeight(.medium)
                    .hAlign(.trailing)
                
                Button {
                    loginUser()
                } label: {
                    Text("Login")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.accentColor)
                }
                .padding(.top, 10)
            }
            
            HStack {
                Text("Didn't have an account yet?")
                    .foregroundColor(.secondary)
                
                Button("Register") {
                    createNewAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $createNewAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError, actions: {  })
    }
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User logged...")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        await MainActor.run(body: {
            userUID = userID
            usernameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Password is gonna be reseted...")
            } catch {
                await setError(error)
            }
        }
    }
    
    /// The error message will be show as an alert
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
