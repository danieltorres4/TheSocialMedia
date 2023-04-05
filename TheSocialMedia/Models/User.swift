//
//  User.swift
//  TheSocialMedia
//
//  Created by Iván Sánchez Torres on 04/04/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userID: String
    var userEmail: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userID
        case userEmail
        case userProfileURL
    }
}
