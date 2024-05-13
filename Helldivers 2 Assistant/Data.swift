//
//  Data.swift
//  Helldivers 2 Assistant
//
//  Created by Leonard Maculo on 5/2/24.
//

import Foundation

struct Welcome: Codable {
    let data: [Datum]
    let error: JSONNull?
    let pagination: Pagination
}

struct Datum: Codable, Hashable {
    let id: Int
    let codename: String?
    let name: String
    let keys: [Key]
    let uses: String
    let cooldown, activation: Int?
    let imageURL: String
    let groupID: Int
    
    enum CodingKeys: String, CodingKey {
        case id, codename, name, keys, uses, cooldown, activation
        case imageURL = "imageUrl"
        case groupID = "groupId"
    }
}

enum Key: String, Codable {
    case down = "down"
    case keyLeft = "left"
    case keyRight = "right"
    case up = "up"
    public static func getRotation(value: Key) -> Double {
        if value == Key.keyRight {
            return 0
        } else if value == Key.down {
            return 90
        } else if value == Key.keyLeft {
            return 180
        } else if value == Key.up {
            return 270
        } else {
            return 0
        }
    }
}

struct Pagination: Codable {
    let page, pageSize, pageCount, total: Int
}

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(0)
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

func fetchJSON(from url: URL, completion: @escaping (Result<Welcome, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Check for errors
        if let error = error {
            completion(.failure(error))
            return
        }
        
        // Check if there's data
        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
            return
        }
        
        // Attempt to decode JSON data
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(Welcome.self, from: data)
            completion(.success(jsonData))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
