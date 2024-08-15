//
//  HomeViewController.swift
//  DogBreedsApp
//
//  Created by Kovid Behl on 2024-08-14.
//


import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var dogBreeds: [DogBreed] = []
    var filteredBreeds: [DogBreed] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        fetchDogBreeds()
    }

    func fetchDogBreeds() {
        let url = URL(string: "https://api.thedogapi.com/v1/breeds")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    var breeds = try decoder.decode([DogBreed].self, from: data)

                    // Map images to breeds
                    for i in 0..<breeds.count {
                        if let imageID = breeds[i].referenceImageID {
                            breeds[i].imageURL = URL(string: "https://cdn2.thedogapi.com/images/\(imageID).jpg")
                        }
                    }

                    self.dogBreeds = breeds
                    self.filteredBreeds = breeds
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }
        task.resume()
    }

    // UISearchBarDelegate method
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredBreeds = dogBreeds
        } else {
            filteredBreeds = dogBreeds.filter { breed in
                breed.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell", for: indexPath) as! BreedTableViewCell
        let breed = filteredBreeds[indexPath.row]
        cell.breedNameLabel.text = breed.name

        if let url = breed.imageURL {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.breedImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            cell.breedImageView.image = nil
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBreedDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedBreed = filteredBreeds[indexPath.row]
                let destinationVC = segue.destination as! BreedDetailsViewController
                destinationVC.breed = selectedBreed
            }
        }
    }
}
