//
//  MyList.swift
//  upcomingtv
//
//  Created by Daniel on 6/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

struct MyList {

    var list: [UTV.Item] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = list
        }
    }

}

private struct UserDefaultsConfig {

    @UserDefault("list", defaultValue: [])
    fileprivate static var list: [UTV.Item]

}
