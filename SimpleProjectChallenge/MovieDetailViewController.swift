//
//  MovieDetailViewController.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 2.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    let movieInfo: Movie?
    var movieDetail: MovieDetail?
    var favoriteDelegate: FavoriteDelegate?
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    
    init(movie: Movie) {
        self.movieInfo = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchMovieDetailData()
        self.title = "Content Details"
        self.navigationItem.rightBarButtonItem = self.createRightBarButton()
    }
    
    func fetchMovieDetailData() {
        let serviceInput = MovieDetailServiceInput(id: (self.movieInfo?.id)!)
        MovieServiceAPI.shared.processOutputData(input: serviceInput){
            (movieDetailResp: MovieDetail) in
            self.movieDetail = movieDetailResp
            self.titleLabel.text = self.movieDetail?.original_title
            self.overviewLabel.text = self.movieDetail?.overview
            if let voteCount = self.movieDetail?.vote_count {
                self.voteCountLabel.text = "Vote Count: \(voteCount)"
            }
            if let posterPath = self.movieDetail?.poster_path {
                self.posterImage.load(url: URL(string: "https://image.tmdb.org/t/p/w200/" + posterPath)!)
            }
        }
    }
    
    func createRightBarButton() -> UIBarButtonItem {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.addTarget(self, action: #selector(addOrRemoveFavorite), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }

    @objc func addOrRemoveFavorite() {
        guard let movieID = self.movieDetail?.id else {
            return
        }
        let key = String(movieID)
        let isFav = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.set(!isFav, forKey: key)
        favoriteDelegate?.favoriteHandler(fav: !isFav, id: movieID)
    }
}
