//
//  WatchedViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class WatchedViewController: UIViewController {

    var collectionViewLayoutManager = CollectionViewLayoutManager()
    var coreDataManager = CoreDataManager()
    var didSelectAt: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let fractionalViewHeight = collectionViewLayoutManager.calculateFractionalCellHeight(from: view)
        collectionView.collectionViewLayout = collectionViewLayoutManager.createCollectionViewLayout(offset: fractionalViewHeight, orientation: .vertical)
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

extension WatchedViewController: UICollectionViewDelegate { }

extension WatchedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            let savedEntities = try coreDataManager.fetchSavedMovieAdditionList(of: .watched)
            return savedEntities.count
        } catch {
            print(error)
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "watchedCell", for: indexPath) as! MovieCollectionViewCell
        
        do {
            let watchedAdditions = try coreDataManager.fetchSavedMovieAdditionList(of: .watched)
            cell.movieId = Int(watchedAdditions[indexPath.row].movieID)
            
            NetworkService.lookup(id: Int(watchedAdditions[indexPath.row].movieID)) { (result) in
                switch result {
                case .success(let movieResponse):
                    if let movie = movieResponse.results.first {
                        DispatchQueue.main.async {
                            cell.loadImage(from: movie.artworkUrl100)
                            cell.titleLabel.text = movie.trackName
                            cell.genre = Genre(rawValue: movie.primaryGenreName)
                        }
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

extension WatchedViewController: DetailViewControllerDelegate {
        
    // Remove movies in CollectionView
    func movieAdditionsRemoved(at indexPath: IndexPath?, type: AdditionType) {
        if type == .watched {
            if let indexPath = indexPath { collectionView.deleteItems(at: [indexPath]) }
            else { collectionView.reloadData() }
        }
    }
    
    // Insert new movies in CollectionView
    func movieAdditionsAdded(additions: [SavedMovieAddition?], type: AdditionType) {
        if type == .watched {
            var indexPaths = [IndexPath]()
            for i in 0..<additions.count { indexPaths.append(IndexPath(row: i, section: 0)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.collectionView.insertItems(at: indexPaths) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.collectionView.reloadItems(at: indexPaths) }
        }
    }
    
}
