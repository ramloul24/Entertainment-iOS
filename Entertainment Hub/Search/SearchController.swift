//
//  SearchController.swift
//  Entertainment Hub
//
//  Created by Michael Lema on 2/23/19.
//  Copyright © 2019 Michael Lema. All rights reserved.
//

import UIKit
import MKProgress

class SearchController: UICollectionViewController {
    
    let cellId = "cellId"
    
    var results = [SearchResult]()
    var filteredResults = [SearchResult]()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for movies & more"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        searchBar.delegate = self
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.App.gray
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        setupSearchBar()
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchShowJSON()
        //searchShow(query: "How")
    }
    
    fileprivate func searchMoviesAndShows(query: String) {
        MKProgress.show(after: 0.1, animated: true)
        let box = GuideBox.search(.none)
        box.searchShows(query: query) { (searchResult, erroe) in
            guard let searchResults = searchResult else { return }
            print("the results are: \(searchResults.count)")
            box.searchMovies(query: query, completion: { (movieResult, error) in
                guard let movieResults = movieResult else { return }
                DispatchQueue.main.async {
                    MKProgress.hide(true)
                    self.results = searchResults + movieResults
                    self.filteredResults = self.results
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    fileprivate func fetchShowJSON() {
        let shows = Subscription(from: .none)
        guard let searchShows = shows.allSearchShows() else { return }
        print(searchShows.count)
        self.results = searchShows
        self.filteredResults = self.results
        self.collectionView.reloadData()
    }
    
    fileprivate func setupSearchBar() {
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, bottom: navBar?.bottomAnchor, left: navBar?.leftAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
}

// MARK: UICollectionViewDataSource
extension SearchController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        cell.result = self.filteredResults[indexPath.item]
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension SearchController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        //let user = filteredUsers[indexPath.item]
        //let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        //userProfileController.user = user
        //navigationController?.pushViewController(userProfileController, animated: true)
    }
}

extension SearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredResults = results
        } else {
            self.filteredResults = self.results.filter { (result) -> Bool in
                return result.title.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if !text.isEmpty {
            self.searchMoviesAndShows(query: text)
        }
        
    }
}
