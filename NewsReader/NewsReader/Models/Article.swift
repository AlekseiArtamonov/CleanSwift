//
//  Feed.swift
//  NewsReader
//
//  Created by Aleksei Artamonov on 7/9/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

public struct Article: Decodable {
    let title: String
    let resource: String
    let imageUrl: URL?
    var image: UIImage? = nil
    let description: String
    let content: String?
    let publishDate: String
    
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case source = "source"
        case imageUrl = "urlToImage"
        case description = "description"
        case content = "content"
        case publishDate = "publishedAt"
    }
    
    enum SourceCodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        do {
            imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        } catch {
            imageUrl = nil
        }
        do {
            description = try container.decode(String.self, forKey: .description)
        } catch {
            description = ""
        }
        publishDate = try container.decode(String.self, forKey: .publishDate)
        do {
            content = try container.decode(String.self, forKey: .content)
        } catch {
            content = ""
        }
        let source = try container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source)
        resource = try source.decode(String.self, forKey: .name)
    }
}
