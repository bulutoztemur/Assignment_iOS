//
//  MoviesListViewController.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import UIKit

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

class MoviesListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isListView = false // true for List View, false for Grid View
    var moviesList: [Movie] = []
    var favData: [Bool] = []
    var filteredFavData: [Bool] = []
    var filteredMoviesList: [Movie] = []
    var isWaiting: Bool = false  // when loading more on bottom, this flag prevents consecutively service call
    var fromWhichCell: Int? = 0
    var fromWhichCellFiltered: Int? = 0
    
    private enum Constants {
        static let gridCellWidthRate: CGFloat = 6
        static let listCellWidthRate: CGFloat = 12
        static let gridCellHeightSize: CGFloat = 250
        static let listCellHeightSize: CGFloat = 400
        static let listIconName: String = "list"
        static let gridIconName: String = "grid"
        static let pageTitle: String = "Contents"
        static let searchBarPlaceholder: String = "Search movies"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if filteredMoviesList.count > 0{
            let movie = self.filteredMoviesList[fromWhichCellFiltered!]
            let key = String(movie.id ?? 0)
            let isFav = UserDefaults.standard.bool(forKey: key)
            if isFav != self.filteredFavData[fromWhichCellFiltered!] {
                self.filteredFavData[fromWhichCellFiltered!] = isFav
                self.favData[fromWhichCell!] = isFav
                let indexPathOfUpdatedCell = IndexPath(row: fromWhichCellFiltered!, section: 0)
                self.collectionView.reloadItems(at: [indexPathOfUpdatedCell])
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAPIDataAndSetToCollectionView()
        self.title = Constants.pageTitle
        self.setRightBarButton()
        self.collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = Constants.searchBarPlaceholder
    }
    
    // MARK: MOVIE REST API CALL
    func fetchAPIDataAndSetToCollectionView() {
        MovieServiceAPI.shared.fetchMovieList() {
            resp in
            switch resp {
            case .success(let result):
                for movie in result.results! {
                    let key = String(movie.id ?? 0)
                    let isFav = UserDefaults.standard.bool(forKey: key)
                    self.favData.append(isFav)
                }
                self.filteredFavData = self.favData
                self.moviesList.append(contentsOf: result.results!)
                self.filteredMoviesList = self.moviesList
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        let windowRect = self.view.window?.frame
        let windowWidth = windowRect?.size.width
        let cellSize = getCellSize()
        return CGSize(width: (cellSize.0 * windowWidth! / 13), height: cellSize.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let movie = filteredMoviesList[indexPath.row]
         for ind in 0..<moviesList.count {
             if movie.id == self.moviesList[ind].id {
                 self.fromWhichCell = ind
             }
         }
        
        self.fromWhichCellFiltered = indexPath.row
        let detailVC = MovieDetailViewController(movie: filteredMoviesList[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func doPaging() {
        self.fetchAPIDataAndSetToCollectionView()
        self.isWaiting = false
    }
    
    func getCellSize() -> (CGFloat, CGFloat) {
        if isListView {
            return (Constants.listCellWidthRate, Constants.listCellHeightSize)
        } else {
            return (Constants.gridCellWidthRate, Constants.gridCellHeightSize)
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
}


