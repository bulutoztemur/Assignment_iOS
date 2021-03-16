//
//  MovieDetail.swift
//  SimpleProjectChallenge
//
//  Created by Alaattin Bulut Öztemur on 3.01.2021.
//  Copyright © 2021 Bulut Oztemur. All rights reserved.
//

import Foundation

public struct MovieDetail: Codable {
    public var id: Int?
    public var original_title: String?
    public var overview: String?
    public var vote_count: Int?
    public var vote_average: Double?
    public var poster_path: String?
}
