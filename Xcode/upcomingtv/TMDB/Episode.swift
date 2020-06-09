//
//  Episode.swift
//
//  Created by Daniel on 5/14/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct Episode: Codable {
    var air_date: String?
    var name: String?
    var overview: String?
    var still_path: String?

    var episode_number: Int?
    var season_number: Int?

    var crew: [Credit]?
    var guest_stars: [Credit]?

    var vote_average: Double
    var vote_count: Int
}
