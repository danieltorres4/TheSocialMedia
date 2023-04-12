//
//  Post.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 10/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    /// Post's content
    var text: String
    var imageURL: URL?
    
    var imageReferenceID: String = ""
    
    var publishedDate: Date = Date()
    
    /// Interaction data
    var likedIDs: [String] = []
    var clappedIDs: [String] = []
    
    /// Post's author basic info
    var userName: String
    var userID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case clappedIDs
        case userName
        case userID
        case userProfileURL
    }
}
