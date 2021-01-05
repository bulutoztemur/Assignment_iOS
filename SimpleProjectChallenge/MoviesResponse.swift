//
//  MoviesResponse.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

public struct MoviesResponse: Codable {
    public var page: Int?
    public var total_results: Int?
    public var total_pages: Int?
    public var results: [Movie]?
}
