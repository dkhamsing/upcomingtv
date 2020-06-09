//
//  Media.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

import Foundation

struct Media: Codable {
    var id: Int

    var title: String?
    var original_title: String?

    var budget: Int?
    var revenue: Int?

    var vote_average: Double
    var vote_count: Int

    var belongs_to_collection: MediaCollection?
    var credits: Credits?
    var external_ids: ExternalIds?
    var genres: [Genre]?
    var homepage: String?
    var original_language: String?
    var overview: String
    var production_companies: [Production]?
    var production_countries: [ProductionCountry]?
    var poster_path: String?
    var recommendations: MediaSearch?
    var release_date: String?
    var runtime: Int?
    var similar: MediaSearch?
    var status: String?
    var tagline: String?
    var videos: VideoSearch?

    // TV
    var original_name: String?
}
