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
    public var pageID = 1

    func fetchGenericData<T:Codable>(input: BaseServiceInput, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: URL(string: input.url)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(T.self, from: data!)
                DispatchQueue.main.async {
                    completion(.success(responseModel))
                }
            } catch let error {
              print(error)
            }
        }).resume()
    }
    
    func processOutputData<T:Codable>(input: BaseServiceInput, process: @escaping (T) -> Void){
        fetchGenericData(input: input, completion: {
                (resp: Result<T, Error>) in
                switch resp {
                case .success(let output):
                    process(output)
                case .failure(let error):
                    print(error.localizedDescription)
                }
        })
    }
    
}
