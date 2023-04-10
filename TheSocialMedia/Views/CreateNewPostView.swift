//
//  NewPostView.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct CreateNewPostView: View {
    var onPost: (Post) -> ()
    
    @State private var postContent: String = ""
    @State private var postImageData: Data?
    
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var username: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    
    /// FocusState is used to toggle the keyboard on and off
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.accentColor)
                }
                .hAlign(.leading)
                
                Button(action: { createPost() }) {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                }
                .disableWithOpacity(postContent == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 15) {
                    TextField("You got the big news ones?", text: $postContent, axis: .vertical)
                        .focused($showKeyboard)
                    
                    if let postImageData, let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        self.postImageData = nil
                                    } label: {
                                        Image(systemName: "x.circle.fill")
                                            .fontWeight(.bold)
                                            .tint(.white)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            Divider()
            
            HStack {
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                .hAlign(.leading)
                
                Button("Done") {
                    showKeyboard = false
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: rawImageData), let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        /// Compressing images to save storage space
                        await MainActor.run(body: {
                            postImageData = compressedImageData
                            photoItem = nil
                        })
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .overlay {
            LoadingView(show: $isLoading)
        }
    }
    
    func createPost() {
        isLoading = true
        showKeyboard = false
        
        Task {
            do {
                guard let profileURL = profileURL else { return }
                
                /// Uploading the image if there is one
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_images").child(imageReferenceID)
                
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    /// Creating a post
                    let post = Post(text: postContent, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: username, userUID: userUID, userProfileURL: profileURL)
                    
                    try await createDocumentAtFirebase(post)
                } else {
                    /// Directly published the post to firebase
                    let post = Post(text: postContent, userName: username, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        let _ = try Firestore.firestore().collection("Posts").addDocument(from: post, completion: { error in
            if error == nil {
                /// The post will be uploaded
                isLoading = false
                onPost(post)
                dismiss()
            }
        })
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct CreateNewPostView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPostView { _ in
            
        }
    }
}
