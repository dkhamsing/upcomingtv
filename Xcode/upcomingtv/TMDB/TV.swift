//
//  TV.swift
//
//  Created by Daniel on 5/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct TV: Codable {
    var id: Int

    var name: String
    var original_name: String

    var first_air_date: String?
    var last_air_date: String?
    var next_episode_to_air: Episode?

    var number_of_episodes: Int?
    var number_of_seasons: Int?

    var vote_average: Double
    var vote_count: Int

    var created_by: [Credit]?
    var episode_run_time: [Int]?
    var genres: [Genre]?
    var homepage: String?
    var origin_country: [String]?
    var original_language: String?
    var overview: String?
    var networks: [TvNetwork]?
    var poster_path: String?
    var production_companies: [Production]?
    var recommendations: TvSearch?

    var seasons: [Season]?
    var status: String?

    var credits: Credits?

    var external_ids: ExternalIds?

    var videos: VideoSearch?
}
