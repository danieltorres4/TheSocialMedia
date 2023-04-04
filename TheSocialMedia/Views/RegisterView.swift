//
//  RegisterView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 03/04/23.
//

import SwiftUI
import PhotosUI

struct RegisterView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePictureData: Data?
    
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Register")
                .font(.system(.largeTitle))
                .fontWidth(.expanded)
                .bold()
                .hAlign(.leading)
            
            Text("Join to the family")
                .font(.title3)
                .fontWidth(.condensed)
                .hAlign(.leading)
            
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            HStack {
                Text("Do you have an account?")
                    .foregroundColor(.secondary)
                
                Button("Login") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            /// extracting UIImage
            if let newValue {
                Task {
                    do {
                        /// UI must be updated on the main thread
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        
                        await MainActor.run(body: {
                            userProfilePictureData = imageData
                        })
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePictureData, let image = UIImage(data: userProfilePictureData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $username)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .border(1, .gray.opacity(0.5))
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .border(1, .gray.opacity(0.5))
            
            TextField("Password", text: $password)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .border(1, .gray.opacity(0.5))
            
            TextField("About you", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .border(1, .gray.opacity(0.5))
            
            TextField("Link (Optional)", text: $userBioLink)
                .textInputAutocapitalization(.never)
                .border(1, .gray.opacity(0.5))
            
            Button {
                
            } label: {
                Text("Done")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.accentColor)
            }
            .padding(.top, 10)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
