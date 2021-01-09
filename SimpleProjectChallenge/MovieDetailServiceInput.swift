//
//  MovieDetailServiceInput.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 6.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import Foundation

class MovieDetailServiceInput: BaseServiceInput {
    var id: Int?
    
    init(id: Int) {
        super.init(url: "https://api.themoviedb.org/3/movie/\(id)?language=en-US&api_key=fd2b04342048fa2d5f728561866ad52a")
    }
}
