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
    public static var pageID = 1
    
    func fetchGenericData<T:Codable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API status: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(T.self, from: validData)
                completion(.success(responseObject))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
        }.resume()
    }
    
    func makeServiceCall<T:Codable>(componentURL: URLComponents, process: @escaping (T) -> Void){
        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }
        
        self.fetchGenericData(url: validURL) { (result: Result<T, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let output):
                    process(output)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
