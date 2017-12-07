//
//  VKResponse.swift
//  VKTest
//
//  Created by ILYA Abramovich on 03.12.2017.
//  Copyright © 2017 ABR. All rights reserved.
//

import Foundation

struct VKResponse: Decodable {
    let response: Response
}

struct Response: Decodable {
    let count: Int
    let items: [Item]
    let profiles: [Profiles]
    let groups: [Groups]
}

struct Item: Decodable {
    let id: Int
    let fromId: Int
    let date: Double
    let markedAsAds: Int?
    let text: String
    let attachments: [Attachments]?
    let copyHistory: [Item]?
    let comments : Comments?
    let likes: Likes?
    let reposts: Reposts?
    let views: Views?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromId = "from_id"
        case date
        case markedAsAds = "marked_as_ads"
        case text
        case attachments
        case copyHistory = "copy_history"
        case comments
        case likes
        case reposts
        case views
    }
}

struct Profiles: Decodable {
    let id: Int
    let firstName: String?
    let lastName : String?
    let photo: URL?
    let online: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case photo = "photo_50"
        case online
    }
}

struct Groups: Decodable {
    let id: Int
    let name: String?
    let photo: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photo = "photo_50"
    }
}

struct Attachments: Decodable {
    let type: String
    let photo: Photo?
    let link: Link?
    let video: Video?
    let doc: Doc?
}

struct Comments: Decodable {
    let count: Int
}

struct Likes: Decodable {
    let count: Int
}

struct Reposts: Decodable {
    let count: Int
}

struct Views: Decodable {
    let count: Int
}

struct Photo: Decodable {
    let photo_75: URL?
    let photo_130: URL?
    let photo_604: URL?
    let photo_807: URL?
    let photo_1280: URL?
    let photo_2560: URL?
    let width: Int
    let height: Int
    let access_key: URL?
}

struct Link: Decodable {
    let url: URL
    let title: String
    let photo: Photo?
}

struct Video: Decodable {
    let title: String
    let duration: Int
    let views: Int
    let photo_130: URL?
    let photo_320: URL?
    let photo_640: URL?
    let photo_800: URL?
}

struct Doc: Decodable {
    let title: String
    let size: Int
    let ext: String
    let url: URL
    let preview: Preview?
}

struct Preview: Decodable {
    let photo: PhotoDoc?
    let video: VideoDoc?
}

struct PhotoDoc: Decodable {
    let sizes: [Sizes]
}

struct Sizes: Decodable {
    let src: URL
    let width: Int
    let height: Int
    let type: String
}

struct VideoDoc: Decodable {
    let src: URL
    let width: Int
    let height: Int
    let file_size: Int
}

// MARK: - Error
// If the response is an error, this structure is used to decode
struct ErrorResponse: Decodable {
    let error: Error
}

struct Error: Decodable {
    let error_code: Int
    let error_msg: String
}

