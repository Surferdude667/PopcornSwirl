//
//  BookmarkViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController {
        
    let coreDataManager = CoreDataManager()
    var didSelectAt: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
}

extension BookmarkViewController: UICollectionViewDelegate { }

extension BookmarkViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            let savedEntities = try coreDataManager.fetchSavedMovieAdditionList(of: .bookmarked)
            return savedEntities.count
        } catch {
            print(error)
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmarkedCell", for: indexPath) as! MovieCollectionViewCell
        
        do {
            let bookmarkedAdditions = try coreDataManager.fetchSavedMovieAdditionList(of: .bookmarked)
            print("CORE DATA FETCH SUCCEDED")
            cell.movieId = Int(bookmarkedAdditions[indexPath.row].movieID)
            
            NetworkService.lookup(id: Int(bookmarkedAdditions[indexPath.row].movieID)) { (result) in
                switch result {
                case .success(let movieResponse):
                    if let movie = movieResponse.results.first {
                        DispatchQueue.main.async {
                            cell.clearImage()
                            cell.titleLabel.text = movie.trackName
                            cell.dateLabel.text = "Bookmarked: \(bookmarkedAdditions[indexPath.row].bookmarked?.date?.toString() ?? "No date found")"
                            cell.genre = Genre(rawValue: movie.primaryGenreName)
                        }
                    
                    cell.loadImage(with: movie.trackId)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        } catch {
            print(error)
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? MovieCollectionViewCell {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movieId = cell.movieId
            detailViewController.genre = cell.genre
            detailViewController.delegate = self
            detailViewController.sentFrom = didSelectAt
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectAt = indexPath
        performSegue(withIdentifier: "toDetailsSeque", sender: collectionView.cellForItem(at: indexPath))
    }
}


extension BookmarkViewController: DetailViewControllerDelegate {
    
    func bookmarkAdditionsRemoved(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            collectionView.deleteItems(at: [indexPath])
        } else {
            print("Reload Data")
            collectionView.reloadData()
        }
    }
    
    func bookmarkAdditionsAdded(additions: [SavedMovieAddition?]) {
        var indexPaths = [IndexPath]()
        
        // Make IndexPath array from additions
        for i in 0..<additions.count {
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        
        print("INDEX PATHS: \(indexPaths): Additions count: \(additions.count) ")
        // Insert items
        
        collectionView.insertItems(at: indexPaths)
        
        
        
    }
    
//    func bookmarkAdditionsChanged(_ newAdditions: [SavedMovieAddition?], destinationIndexPath: IndexPath?) {
//
//
//        if let indexPath = destinationIndexPath {
//            collectionView.deleteItems(at: [indexPath])
//        } else if newAdditions.count > 0 {
//            var indexPaths = [IndexPath]()
//
//            for i in 0..<newAdditions.count {
//                indexPaths.append(IndexPath(row: i, section: 0))
//            }
//
//            collectionView.insertItems(at: indexPaths)
//        }
//    }
}
