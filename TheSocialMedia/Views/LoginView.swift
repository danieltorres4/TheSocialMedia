//
//  LoginView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 03/04/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var createNewAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
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
        .fullScreenCover(isPresented: $createNewAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError, actions: {  })
    }
    
    func loginUser() {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User logged...")
            } catch {
                await setError(error)
            }
        }
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
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    func disableWithOpacity(_ condition: Bool) -> some View {
        self.disabled(condition).opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self.padding(.horizontal, 15).padding(.vertical, 10).background {
            RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(color, lineWidth: width)
        }
    }
    
    func fillView(_ color: Color) -> some View {
        self.padding(.horizontal, 15).padding(.vertical, 10).background {
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(color)
        }
    }
}
