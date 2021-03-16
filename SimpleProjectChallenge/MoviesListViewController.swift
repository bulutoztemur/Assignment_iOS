//
//  MoviesListViewController.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import UIKit

protocol FavoriteDelegate : class{
    func favoriteHandler(fav: Bool, id: Int)
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

class MoviesListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, FavoriteDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isListView = false // true for List View, false for Grid View
    var moviesList: [Movie] = []
    var favData: [Bool] = []
    var filteredFavData: [Bool] = []
    var filteredMoviesList: [Movie] = []
    var isWaiting: Bool = false  // when loading more on bottom, this flag prevents consecutively service call
    var fromWhichCellFiltered: Int? = 0
    let screenWidth = UIScreen.main.bounds.size.width
    
    private enum Constants {
        static let gridCellWidthRate: CGFloat = 6
        static let listCellWidthRate: CGFloat = 12
        static let listIconName: String = "list"
        static let gridIconName: String = "grid"
        static let pageTitle: String = "Contents"
        static let searchBarPlaceholder: String = "Search movies"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchMovieData()
        self.title = Constants.pageTitle
        self.setRightBarButton()
        self.collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = Constants.searchBarPlaceholder
    }
        
    // MARK: MOVIE REST API CALL
    func fetchMovieData() {
        MovieServiceAPI.shared.makeServiceCall(componentURL: self.createComponentURL()) {[weak self] (output: MoviesResponse) in
            guard let self = self else {
                return
            }
            MovieServiceAPI.pageID += 1
            for movie in output.results! {
                let key = String(movie.id ?? 0)
                let isFav = UserDefaults.standard.bool(forKey: key)
                self.favData.append(isFav)
            }
            self.filteredFavData = self.favData
            self.moviesList.append(contentsOf: output.results!)
            self.filteredMoviesList = self.moviesList
            self.collectionView.reloadData()
        }
    }
    
    func createComponentURL() -> URLComponents {
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.themoviedb.org"
        componentURL.path = "/3/movie/popular"
        let queryItemLanguage = URLQueryItem(name: "language", value: "en-US")
        let queryItemAPIKey = URLQueryItem(name: "api_key", value: "fd2b04342048fa2d5f728561866ad52a")
        let queryItemPageID = URLQueryItem(name: "page", value: String(MovieServiceAPI.pageID))
        componentURL.queryItems = [queryItemLanguage, queryItemAPIKey, queryItemPageID]
        return componentURL
    }
    
    // MARK: COLLECTION VIEW DELEGATE AND DATA SOURCE METHODS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMoviesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MovieCollectionViewCell)?.configureCell(isFavorite: filteredFavData[indexPath.row], movieData: self.filteredMoviesList[indexPath.row])
        
        if indexPath.row == self.collectionView.numberOfItems(inSection: 0) - 2 && !isWaiting {
           isWaiting = true
           self.doPaging()
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidthRate = getCellWidthRate()
        let cellWidth = cellWidthRate * (screenWidth - 30) / 12  // minus 30 ==> 10 constraint left + 10 constraint rigth side + 10 distance between cell in grid mode
        let cellHeight = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.fromWhichCellFiltered = indexPath.row
        let detailVC = MovieDetailViewController(movie: filteredMoviesList[indexPath.row])
        detailVC.favoriteDelegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func doPaging() {
        self.fetchMovieData()
        self.isWaiting = false
    }
    
    func getCellWidthRate() -> CGFloat {
        if isListView {
            return (Constants.listCellWidthRate)
        } else {
            return (Constants.gridCellWidthRate)
        }
    }
    
    @objc func switchToListOrGridView() {
        self.collectionView.reloadData()
        isListView = !isListView
        self.setRightBarButton()
    }
        
    func createRightBarButton() -> UIBarButtonItem {
        let iconName = getIconName()
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: iconName), for: .normal)
        button.addTarget(self, action: #selector(switchToListOrGridView), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }
    
    func getIconName() -> String {
        return isListView ? Constants.gridIconName : Constants.listIconName
    }
    
    func setRightBarButton() {
        self.navigationItem.rightBarButtonItem = createRightBarButton()
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredMoviesList = []
        self.filteredFavData = []
        if searchText == "" {
            filteredMoviesList = moviesList
            filteredFavData = favData
            self.isWaiting = false // Search mode is over. It allows service call any more.
        } else {
            self.isWaiting = true // It stops service call in search mode
            for i in 0..<self.moviesList.count {
                if (self.moviesList[i].title?.lowercased().contains(searchText.lowercased()))!{
                    self.filteredMoviesList.append(self.moviesList[i])
                    self.filteredFavData.append(self.favData[i])
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    // MARK: FAVORITE DELEGATE METHOD
    func favoriteHandler(fav: Bool, id: Int) {
        let fromWhichCell = self.findMovieIndexInNonFilterArray(movieID: id)
        self.favData[fromWhichCell] = fav
        self.filteredFavData[fromWhichCellFiltered!] = fav
        let indexPathOfUpdatedCell = IndexPath(row: fromWhichCellFiltered!, section: 0)
        self.collectionView.reloadItems(at: [indexPathOfUpdatedCell])
    }
    
    func findMovieIndexInNonFilterArray(movieID: Int) -> Int {
        var indexMovie: Int?
        for index in 0..<moviesList.count {
            if movieID == self.moviesList[index].id {
                indexMovie = index
            }
        }
        return indexMovie!
    }
}

