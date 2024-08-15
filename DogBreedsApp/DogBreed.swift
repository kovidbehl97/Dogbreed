//
//  DogBreed.swift
//  DogBreedsApp
//
//  Created by Kovid Behl on 2024-08-14.
//

import Foundation

struct DogBreed: Decodable {
    let id: Int
    let name: String
    let breedGroup: String?
    let lifeSpan: String
    let temperament: String?
    let referenceImageID: String?
    var imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, name, breedGroup = "breed_group"
        case lifeSpan = "life_span", temperament, referenceImageID = "reference_image_id"
    }
}

