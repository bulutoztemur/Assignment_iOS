//
//  MovieServiceAPI.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import Foundation

class MovieServiceAPI {
    public static let shared = MovieServiceAPI() //Singleton object
    private init() {} //No one can create instance
    private var pageID = 1

    func fetchMovieList(completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&api_key=fd2b04342048fa2d5f728561866ad52a&page=\(pageID)")!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(MoviesResponse.self, from: data!)
                self.pageID += 1
                DispatchQueue.main.async {
                    completion(.success(responseModel))
                }
            } catch let error {
              print(error)
            }
        }).resume()
    }
    
    
    func fetchMovieDetail(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/3/movie/\(id)?language=en-US&api_key=fd2b04342048fa2d5f728561866ad52a")!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(MovieDetail.self, from: data!)
                DispatchQueue.main.async {
                    completion(.success(responseModel))
                }
            } catch let error {
              print(error)
            }
        }).resume()
    }
}
