//
//  MovieServiceInput.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 9.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import Foundation

class MovieServiceInput: BaseServiceInput {
    public static var pageID = 1
    init() {
        super.init(url: "https://api.themoviedb.org/3/movie/popular?language=en-US&api_key=fd2b04342048fa2d5f728561866ad52a&page=\(MovieServiceInput.pageID)")
    }
}
