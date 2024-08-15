//
//  BreedDetailsViewController.swift
//  DogBreedsApp
//
//  Created by Kovid Behl on 2024-08-14.
//

import UIKit
import CoreData

class BreedDetailsViewController: UIViewController {

    @IBOutlet weak var breedImageView: UIImageView!
    @IBOutlet weak var breedNameLabel: UILabel!
    @IBOutlet weak var breedGroupLabel: UILabel!
    @IBOutlet weak var lifeSpanLabel: UILabel!
    @IBOutlet weak var temperamentLabel: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!

    var breed: DogBreed?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        guard let breed = breed else { return }
        breedNameLabel.text = breed.name
        breedGroupLabel.text = breed.breedGroup ?? "Unknown"
        lifeSpanLabel.text = breed.lifeSpan
        temperamentLabel.text = breed.temperament ?? "Unknown"

        if let url = breed.imageURL {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.breedImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            breedImageView.image = nil
        }
    }

    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        guard let breed = breed else { return }

        if isBreedAlreadyFavorite(breed) {
            showAlert(title: "Already Added", message: "\(breed.name) is already in your favorites.")
            return
        }
        
        saveToFavorites()
    }

    private func isBreedAlreadyFavorite(_ breed: DogBreed) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteBreed> = FavoriteBreed.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", breed.name )

        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to check if breed is favorite: \(error)")
            return false
        }
    }

    private func saveToFavorites() {
        guard let breed = breed else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let favoriteBreed = FavoriteBreed(context: context)
        favoriteBreed.name = breed.name
        favoriteBreed.breedGroup = breed.breedGroup
        favoriteBreed.lifeSpan = breed.lifeSpan
        favoriteBreed.temperament = breed.temperament
        favoriteBreed.imageURL = breed.imageURL?.absoluteString
        
        do {
            try context.save()
            showAlert(title: "Success", message: "\(breed.name) has been added to your favorites.")
        } catch {
            showAlert(title: "Error", message: "Failed to add \(breed.name) to favorites.")
            print("Failed to save breed: \(error)")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
