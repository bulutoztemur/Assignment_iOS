//
//  MovieCollectionViewCell.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var moviePoster: UIImageView!
    
    func configureCell(isFavorite: Bool, movieData: Movie) {
        if isFavorite {
            self.favoriteIcon.isHidden = false
        } else {
            self.favoriteIcon.isHidden = true
        }
        self.movieTitleLabel.text = movieData.title
        if let posterPath = movieData.poster_path {
            self.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/w200/" + posterPath)!)
        }
        self.layer.cornerRadius = 5.0
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
