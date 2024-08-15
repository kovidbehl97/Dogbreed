//
//  FavoriteBreed+CoreDataProperties.swift
//  DogBreedsApp
//
//  Created by Kovid Behl on 2024-08-14.
//
//

import Foundation
import CoreData


extension FavoriteBreed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteBreed> {
        return NSFetchRequest<FavoriteBreed>(entityName: "FavoriteBreed")
    }

    @NSManaged public var lifeSpan: String?
    @NSManaged public var name: String?
    @NSManaged public var breedGroup: String?
    @NSManaged public var temperament: String?
    @NSManaged public var imageURL: String?

}

extension FavoriteBreed : Identifiable {

}
