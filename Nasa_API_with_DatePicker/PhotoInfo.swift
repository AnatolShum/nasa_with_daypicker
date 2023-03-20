//
//  PhotoInfo.swift
//  Nasa_API_with_DatePicker
//
//  Created by Anatolii Shumov on 24/02/2023.
//

import Foundation

struct PhotoInfo: Codable {
    var title: String
    var description: String
    var url: URL
    var copyright: String?

    enum CodingKeys: String, CodingKey {
        case title
        case description = "explanation"
        case url
        case copyright
    }

}
