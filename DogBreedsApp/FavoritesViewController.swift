//
//  FavoritesViewController.swift
//  DogBreedsApp
//
//  Created by Kovid Behl on 2024-08-14.
//

import UIKit
import CoreData
class FavoriteBreedTableViewCell: UITableViewCell {
    @IBOutlet weak var breedImageViewFav: UIImageView!
     @IBOutlet weak var breedNameLabelFav: UILabel!
}
class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favoriteBreeds: [FavoriteBreed] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchFavorites()
        tableView.allowsSelection = true
    }

    func fetchFavorites() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteBreed> = FavoriteBreed.fetchRequest()
        
        do {
            favoriteBreeds = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteBreedTableViewCell
        
        let favorite = favoriteBreeds[indexPath.row]
        cell.breedNameLabelFav.text = favorite.name

        if let imageURLString = favorite.imageURL, let url = URL(string: imageURLString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            cell.breedImageViewFav.image = image
                        }
                    }
                }
            }.resume()
        } else {
            cell.imageView?.image = nil
        }


        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favoriteBreeds[indexPath.row]
        // Handle cell selection if needed
    }
    
    // Implement swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the breed from Core Data
            let breedToDelete = favoriteBreeds[indexPath.row]
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(breedToDelete)
            
            do {
                try context.save()
                favoriteBreeds.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete breed: \(error)")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavoriteDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let favorite = favoriteBreeds[indexPath.row]
                let detailsVC = segue.destination as! BreedDetailsViewController
                detailsVC.breed = DogBreed(
                    id: 0,  // Default value
                    name: favorite.name ?? "",
                    breedGroup: favorite.breedGroup,
                    lifeSpan: favorite.lifeSpan ?? "",
                    temperament: favorite.temperament,
                    referenceImageID: favorite.imageURL ?? "",  // Use image URL as a reference ID if applicable
                    imageURL: favorite.imageURL != nil ? URL(string: favorite.imageURL!) : nil
                )
            }
        }
    }

}
