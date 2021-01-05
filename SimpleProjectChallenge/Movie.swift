//
//  Movie.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 1.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

public struct Movie: Codable {
    public let id: Int?
    public let title: String?
    public let overview: String?
    public let release_date: String?
    public let vote_average: Double?
    public let vote_count: Int?
    public let adult: Bool?
    public let backdrop_path: String?
    public let genre_ids: [Int]?
    public let original_language: String?
    public let original_title: String?
    public let poster_path: String?
    public let popularity: Double?
    public let video: Bool?
}
