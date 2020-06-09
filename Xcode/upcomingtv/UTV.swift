//
//  UTV.swift
//  upcomingtv
//
//  Created by Daniel on 6/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct UTV {

    struct Section {
        var header: String?
        var items: [Item]?
    }

    struct Item: Codable {
        var id: Int?
        var title: String?
        var subtitle: String?

        var nextEpisode: Episode?
    }

}

extension UTV.Item: Equatable {

    static func ==(lhs: UTV.Item, rhs: UTV.Item) -> Bool {
        return lhs.id == rhs.id
    }

}
